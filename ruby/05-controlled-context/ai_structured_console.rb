# frozen_string_literal: true

require "json"
require "securerandom"

require_relative "ai_call_boundary"
require_relative "failure_classification"
require_relative "retry_policy"
require_relative "latency_budget"
require_relative "cost_guard"
require_relative "safety_fallback"
require_relative "trust_contract"
require_relative "context/analysis_context"

# ============================================================
# Phase 5.2 — Intent Inference
# Determines WHAT the user is asking for
# ============================================================
def infer_focus(user_prompt)
  case user_prompt
  when /what does|what is|meaning of/i
    :status_meaning
  when /what should I do|next|proceed/i
    :next_action
  when /why|error|failed|problem|cause/i
    :error_meaning
  else
    :status_meaning
  end
end

# ============================================================
# Phase 5.3 — Blocking & Responsibility
# Determines IF the system can answer safely
# ============================================================
def determine_blocking(context)
  focus  = context.current_focus
  status = context.file_state[:status]

  blocking = {
    is_blocked: false,
    reason: nil,
    responsibility: :NONE
  }

  if focus == :error_meaning
    case status
    when "MAPPING_ERROR"
      blocking = {
        is_blocked: true,
        reason: :INSUFFICIENT_TRANSACTION_CONTEXT,
        responsibility: :USER
      }
    when "PROCESSING"
      blocking = {
        is_blocked: true,
        reason: :SYSTEM_STILL_PROCESSING,
        responsibility: :SYSTEM
      }
    end
  end

  blocking
end

# ============================================================
# AI boundary setup (unchanged v0.4.x → v0.5.x)
# ============================================================
api_key = ENV["OPENAI_API_KEY"]
model   = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

ai = AiCallBoundary.new(
  api_key: api_key,
  model: model
)

# ============================================================
# Base system prompt
# ============================================================
BASE_SYSTEM_PROMPT = <<~PROMPT
  You are an AI analyst assistant for a payment reconciliation system.
PROMPT

# ============================================================
# Phase 5.4 — Bounded Reasoning Configuration
# ============================================================
INITIAL_REASONING_BUDGET = 2

# ============================================================
# Phase 5.5 — Session Lifecycle State
# ============================================================
lifecycle_state  = :ACTIVE
reasoning_budget = { turns_remaining: INITIAL_REASONING_BUDGET }
last_status      = nil
last_subject     = nil

puts "Enter your question (or type 'exit'):"

# ============================================================
# Console Interaction Loop (Single User Session)
# ============================================================
while (input = STDIN.gets&.strip)
  break if input.downcase == "exit"

  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  # ==========================================================
  # Phase 5.5 — Intentional Forgetting
  # Reset semantic context when lifecycle is not ACTIVE
  # ==========================================================
  if lifecycle_state != :ACTIVE
    reasoning_budget = { turns_remaining: INITIAL_REASONING_BUDGET }
    last_status      = nil
    last_subject     = nil
    lifecycle_state  = :ACTIVE
  end

  # ==========================================================
  # Retry Loop
  # ==========================================================
  loop do
    begin
      CostGuard.record!

      # ------------------------------------------------------
      # Phase 5.2 — Intent inference
      # ------------------------------------------------------
      focus = infer_focus(input)

      # ------------------------------------------------------
      # Phase 5.4 — Continuity Binding
      # Allows ONE contextual "why"
      # ------------------------------------------------------
      file_state =
        if focus == :error_meaning && last_status
          { status: last_status, status_category: "ERROR" }
        else
          { status: "MAPPING_ERROR", status_category: "ERROR" }
        end

      # ------------------------------------------------------
      # Phase 5.4 — Reasoning Budget Enforcement
      # ------------------------------------------------------
      if reasoning_budget[:turns_remaining] <= 0
        lifecycle_state = :EXHAUSTED

        response = {
          status: "BLOCKED",
          reason: :REASONING_BUDGET_EXHAUSTED,
          responsibility: :USER,
          message: "This discussion has reached its reasoning limit. Please start a new analysis."
        }

        puts JSON.pretty_generate(
          TrustContract.success(response)
        )
        break
      end

      # ------------------------------------------------------
      # Build base AnalysisContext
      # ------------------------------------------------------
      base_context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" }, # placeholder
        file_state: file_state,
        current_focus: focus,
        reasoning_budget: reasoning_budget,
        lifecycle: { state: lifecycle_state, created_at: Time.now },
        blocking_condition: nil
      )

      # ------------------------------------------------------
      # Phase 5.3 — Blocking Decision
      # ------------------------------------------------------
      blocking = determine_blocking(base_context)

      context = AnalysisContext.new(
        session_id: base_context.session_id,
        subject: base_context.subject,
        file_state: base_context.file_state,
        current_focus: base_context.current_focus,
        reasoning_budget: base_context.reasoning_budget,
        lifecycle: base_context.lifecycle,
        blocking_condition: blocking
      )

      # ------------------------------------------------------
      # Phase 5.3 — Blocked Response (Terminal)
      # ------------------------------------------------------
      if context.blocking_condition[:is_blocked]
        lifecycle_state = :COMPLETED

        response = {
          status: "BLOCKED",
          reason: context.blocking_condition[:reason],
          responsibility: context.blocking_condition[:responsibility],
          message: "This line of inquiry cannot continue further."
        }

        puts JSON.pretty_generate(
          TrustContract.success(response)
        )
        break
      end

      # ------------------------------------------------------
      # Phase 5.2 — Focused System Prompt
      # JSON instruction MUST be last
      # ------------------------------------------------------
      system_prompt =
        case focus
        when :status_meaning
          <<~PROMPT
            #{BASE_SYSTEM_PROMPT}
            Explain what this status means.
            Return responses strictly in JSON.
          PROMPT
        when :error_meaning
          <<~PROMPT
            #{BASE_SYSTEM_PROMPT}
            Explain why this error occurred.
            Return responses strictly in JSON.
          PROMPT
        when :next_action
          <<~PROMPT
            #{BASE_SYSTEM_PROMPT}
            Explain what the user should do next.
            Return responses strictly in JSON.
          PROMPT
        else
          <<~PROMPT
            #{BASE_SYSTEM_PROMPT}
            Return responses strictly in JSON.
          PROMPT
        end

      # ------------------------------------------------------
      # AI Call (Boundary unchanged)
      # ------------------------------------------------------
      result = ai.explain(
        system_prompt: system_prompt,
        user_prompt: input
      )

      # ------------------------------------------------------
      # Phase 5.4 — Commit Continuity & Budget
      # ------------------------------------------------------
      reasoning_budget[:turns_remaining] -= 1
      last_status  = context.file_state[:status]
      last_subject = context.subject

      # ------------------------------------------------------
      # Phase 5.5 — Optional lifecycle closure on action guidance
      # ------------------------------------------------------
      lifecycle_state = :COMPLETED if focus == :next_action

      puts JSON.pretty_generate(
        TrustContract.success(result)
      )
      break

    rescue => e
      failure = FailureClassification.classify(e)

      break unless RetryPolicy.retry?(failure, attempt)
      break if LatencyBudget.exceeded?
      break if CostGuard.exceeded?

      attempt += 1
    end
  end

  # ==========================================================
  # Terminal Failure Handling
  # ==========================================================
  if failure
    lifecycle_state = :COMPLETED
    fallback = SafetyFallback.build(failure)

    puts JSON.pretty_generate(
      TrustContract.failure(fallback)
    )
  end

  puts "\nEnter another question:"
end
