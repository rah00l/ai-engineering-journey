# frozen_string_literal: true

require "json"
require "securerandom"
require "debug"

require_relative "ai_call_boundary"
require_relative "failure_classification"
require_relative "retry_policy"
require_relative "latency_budget"
require_relative "cost_guard"
require_relative "safety_fallback"
require_relative "trust_contract"
require_relative "context/analysis_context"

# ============================================================
# Phase 6.x — Knowledge Governance & Discipline (Phase 3)
# ============================================================
require_relative "eligibility/knowledge_eligibility_gate"
require_relative "adapter/pdf_document_adapter"
require_relative "grounding/grounded_explanation_controller"

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

def extract_term_from_user_input(user_input)
  match = user_input.match(/what does\s+(.+?)\s+mean\?/i)
  return nil unless match

  match[1].strip.upcase
end

# ============================================================
# AI boundary setup (unchanged v0.4.x → v0.5.x)
# ============================================================
ai = AiCallBoundary.new(
  api_key: ENV["OPENAI_API_KEY"],
  model: ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")
)

# ============================================================
# Phase 7.0 — Grounded Execution Components
# ============================================================
document_adapter = PdfDocumentAdapter.new

grounded_controller =
  GroundedExplanationController.new(
    document_adapter: document_adapter,
    ai: ai
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
  next if input.empty?

  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  # ==========================================================
  # Phase 5.5 — Intentional Forgetting
  # ==========================================================
  if lifecycle_state != :ACTIVE
    reasoning_budget = { turns_remaining: INITIAL_REASONING_BUDGET }
    last_status      = nil
    last_subject     = nil
    lifecycle_state  = :ACTIVE
  end

  loop do
    begin
      CostGuard.record!

      # ------------------------------------------------------
      # Phase 5.2 — Intent inference
      # ------------------------------------------------------
      focus = infer_focus(input)

      # ------------------------------------------------------
      # Phase 5.4 — Continuity Binding
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

        puts JSON.pretty_generate(
          TrustContract.success(
            status: "BLOCKED",
            reason: :REASONING_BUDGET_EXHAUSTED,
            responsibility: :USER,
            message: "This discussion has reached its reasoning limit. Please start a new analysis."
          )
        )
        break
      end

      # ------------------------------------------------------
      # Build AnalysisContext
      # ------------------------------------------------------
      base_context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" },
        file_state: file_state,
        current_focus: focus,
        reasoning_budget: reasoning_budget,
        lifecycle: { state: lifecycle_state, created_at: Time.now },
        blocking_condition: nil
      )

      blocking = determine_blocking(base_context)

      context = AnalysisContext.new(
        **base_context.to_h,
        blocking_condition: blocking
      )

      # ------------------------------------------------------
      # Phase 5.3 — Blocked Response
      # ------------------------------------------------------
      if context.blocking_condition[:is_blocked]
        lifecycle_state = :COMPLETED

        puts JSON.pretty_generate(
          TrustContract.success(
            status: "BLOCKED",
            reason: context.blocking_condition[:reason],
            responsibility: context.blocking_condition[:responsibility],
            message: "This line of inquiry cannot continue further."
          )
        )
        break
      end

      # ------------------------------------------------------
      # Phase 6.1 — Knowledge Eligibility Gate
      # Determines IF documentation may be consulted
      # ------------------------------------------------------
      eligibility =
        KnowledgeEligibilityGate.evaluate(
          intent: context.current_focus,
          domain: :reconciliation
        )

      # ------------------------------------------------------
      # Phase 5.2 — Focused System Prompt
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
        end

      # ------------------------------------------------------
      # Phase 7.0 — Grounded vs Ungrounded Execution
      # SINGLE EXECUTION FORK
      # ------------------------------------------------------
      result =
        if eligibility.allowed?

          term = extract_term_from_user_input(input)

          return not_defined unless term

          grounded_controller.explain(
            context: context,
            eligibility: eligibility,
            source: "RECONCILIATION_HANDBOOK",
            section: :definitions,
            version: "v2.1",
            term: term,
            system_prompt: system_prompt,
            user_prompt: input
          )
        else
          ai.explain(
            system_prompt: system_prompt,
            user_prompt: input
          )
        end

      reasoning_budget[:turns_remaining] -= 1
      last_status = context.file_state[:status]
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

   puts "\nEnter your question (or type 'exit'):"
end