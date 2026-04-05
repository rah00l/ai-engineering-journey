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
# Phase 5.2 helper
# MUST be defined BEFORE main loop (Ruby rule)
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
# AI boundary setup (unchanged from v0.4.x)
# ============================================================
api_key = ENV["OPENAI_API_KEY"]
model   = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

ai = AiCallBoundary.new(
  api_key: api_key,
  model: model
)

# ============================================================
# Base system prompt (authoritative, reused)
# ============================================================
BASE_SYSTEM_PROMPT = <<~PROMPT
  You are an AI analyst assistant for a payment reconciliation system.
PROMPT

# ============================================================
# Console interaction loop (outer loop)
# ============================================================
puts "Enter your question (or type 'exit'):"

while (input = STDIN.gets&.strip)

  break if input.downcase == "exit"

  # Reset safety guards per question
  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  # ========================================================
  # Retry loop (inner loop)
  # ========================================================
  loop do
    begin
      # ----------------------------
      # Guard accounting
      # ----------------------------
      CostGuard.record!

      # ----------------------------
      # Phase 5.2: intent extraction
      # ----------------------------
      focus = infer_focus(input)

      # ----------------------------
      # Phase 5.2: build context
      # (local reasoning only)
      # ----------------------------
      context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" }, # placeholder
        file_state: {
          status: "MAPPING_ERROR",
          status_category: "ERROR"
        },
        current_focus: focus,

        # Phase 5.2 placeholders (not used yet)
        reasoning_budget: { turns_remaining: nil },
        lifecycle: { created_at: Time.now }
      )

      # ----------------------------
      # Phase 5.2: focused system prompt
      # IMPORTANT: JSON rule is LAST
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
      # AI call (boundary unchanged)
      # ----------------------------
      result = ai.explain(
        system_prompt: system_prompt,
        user_prompt: input
      )

      # ----------------------------
      # Success path
      # ----------------------------
      puts JSON.pretty_generate(
        TrustContract.success(result)
      )

      break  # <-- exits retry loop

    rescue => e
      # ----------------------------
      # Failure handling
      # ----------------------------
      failure = FailureClassification.classify(e)

      puts "DEBUG_EXCEPTION_CLASS: #{e.class}"
      puts "DEBUG_EXCEPTION_MESSAGE: #{e.message}"
      puts e.backtrace.take(5).join("\n")

      break unless RetryPolicy.retry?(failure, attempt)
      break if LatencyBudget.exceeded?
      break if CostGuard.exceeded?

      attempt += 1
    end
  end

  # ==========================================================
  # Terminal failure path (after retries)
  # ==========================================================
  if failure
    fallback = SafetyFallback.build(failure)
    puts JSON.pretty_generate(
      TrustContract.failure(fallback)
    )
  end

  puts "\nEnter another question:"
end