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
# Phase 5.2 helper — intent inference
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
# Phase 5.3 helper — blocking & responsibility
# ============================================================
def determine_blocking(context)
  focus  = context.current_focus
  status = context.file_state[:status]

  # Default: not blocked
  blocking = {
    is_blocked: false,
    reason: nil,
    responsibility: :NONE
  }

  # --- Phase 5.3 blocking rules ---
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
# AI boundary setup (unchanged from v0.4.x)
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
# Console interaction loop
# ============================================================
puts "Enter your question (or type 'exit'):"

while (input = STDIN.gets&.strip)
  break if input.downcase == "exit"

  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  # ========================================================
  # Retry loop
  # ========================================================
  loop do
    begin
      CostGuard.record!

      # ----------------------------
      # Phase 5.2 — intent inference
      # ----------------------------
      focus = infer_focus(input)

      # ----------------------------
      # Phase 5.2 — initial context
      # ----------------------------
      base_context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" }, # placeholder
        file_state: {
          status: "MAPPING_ERROR",
          status_category: "ERROR"
        },
        current_focus: focus,
        reasoning_budget: { turns_remaining: nil },
        lifecycle: { created_at: Time.now },
        blocking_condition: nil
      )

      # ----------------------------
      # Phase 5.3 — determine blocking
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
      # Phase 5.3 — blocked response path
      # ----------------------------
      if context.blocking_condition[:is_blocked]
        response = {
          status: "BLOCKED",
          reason: context.blocking_condition[:reason],
          responsibility: context.blocking_condition[:responsibility],
          message: case context.blocking_condition[:responsibility]
                   when :USER
                     "More information is required to determine why this happened."
                   when :SYSTEM
                     "The system has not completed processing yet."
                   when :SUPPORT
                     "This requires investigation by the support team."
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
      # Phase 5.2 — focused explanation prompt
      # (JSON instruction MUST be last)
      # ----------------------------
      system_prompt =
        case context.current_focus
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
      # AI call (unchanged boundary)
      # ----------------------------
      result = ai.explain(
        system_prompt: system_prompt,
        user_prompt: input
      )

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
  # Terminal failure path
  # ==========================================================
  if failure
    fallback = SafetyFallback.build(failure)
    puts JSON.pretty_generate(
      TrustContract.failure(fallback)
    )
  end

  puts "\nEnter another question:"
end