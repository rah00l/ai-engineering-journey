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
# AI boundary setup (unchanged from v0.4.x → v0.5.x)
# ============================================================
api_key = ENV["OPENAI_API_KEY"]
model   = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

ai = AiCallBoundary.new(
  api_key: api_key,
  model: model
)

# ============================================================
# Base system prompt (authoritative)
# ============================================================
BASE_SYSTEM_PROMPT = <<~PROMPT
  You are an AI analyst assistant for a payment reconciliation system.
PROMPT

# ============================================================
# Phase 5.4 — Bounded Reasoning Configuration
# ============================================================
INITIAL_REASONING_BUDGET = 2

# ============================================================
# Phase 5.4 — Session‑Scoped Continuity State
# These MUST NOT reset per question
# ============================================================
reasoning_budget = {
  turns_remaining: INITIAL_REASONING_BUDGET
}

last_status  = nil
last_subject = nil

puts "Enter your question (or type 'exit'):"

# ============================================================
# Console Interaction Loop (User Session)
# ============================================================
while (input = STDIN.gets&.strip)
  break if input.downcase == "exit"

  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  # ========================================================
  # Retry Loop
  # ========================================================
  loop do
    begin
      CostGuard.record!

      # ----------------------------
      # Phase 5.2 — Intent inference
      # ----------------------------
      focus = infer_focus(input)

      # ----------------------------
      # Phase 5.4 — Continuity Binding
      # Allows ONE follow‑up "why" using last_status
      # ----------------------------
      file_state =
        if focus == :error_meaning && last_status
          { status: last_status, status_category: "ERROR" }
        else
          { status: "MAPPING_ERROR", status_category: "ERROR" }
        end

      # ----------------------------
      # Phase 5.4 — Reasoning Budget Check
      # ----------------------------
      if reasoning_budget[:turns_remaining] <= 0
        response = {
          status: "BLOCKED",
          reason: :REASONING_BUDGET_EXHAUSTED,
          responsibility: :USER,
          message: "Further reasoning requires restarting the analysis or providing more context."
        }

        puts JSON.pretty_generate(
          TrustContract.success(response)
        )
        break
      end

      # ----------------------------
      # Phase 5.2 — Base Context
      # ----------------------------
      base_context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" }, # placeholder
        file_state: file_state,
        current_focus: focus,
        reasoning_budget: reasoning_budget,
        lifecycle: { created_at: Time.now },
        blocking_condition: nil
      )

      # ----------------------------
      # Phase 5.3 — Blocking Decision
      # ----------------------------
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

      # ----------------------------
      # Phase 5.3 — Blocked Response Path
      # ----------------------------
      if context.blocking_condition[:is_blocked]
        response = {
          status: "BLOCKED",
          reason: context.blocking_condition[:reason],
          responsibility: context.blocking_condition[:responsibility],
          message: case context.blocking_condition[:responsibility]
                   when :USER
                     "More details are required to answer this question."
                   when :SYSTEM
                     "The system has not completed processing yet."
                   else
                     "This request is currently blocked."
                   end
        }

        puts JSON.pretty_generate(
          TrustContract.success(response)
        )
        break
      end

      # ----------------------------
      # Phase 5.2 — Focused System Prompt
      # IMPORTANT: JSON instruction MUST be last
      # ----------------------------
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

      # ----------------------------
      # AI Call (Boundary Remains Unchanged)
      # ----------------------------
      result = ai.explain(
        system_prompt: system_prompt,
        user_prompt: input
      )

      # ----------------------------
      # Phase 5.4 — Commit Continuity
      # These MUST happen AFTER a successful explanation
      # ----------------------------
      reasoning_budget[:turns_remaining] -= 1
      last_status  = context.file_state[:status]
      last_subject = context.subject

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
    fallback = SafetyFallback.build(failure)
    puts JSON.pretty_generate(
      TrustContract.failure(fallback)
    )
  end

  puts "\nEnter another question:"
end