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
require_relative "intent_resolver"

# ============================================================
# Phase 6.x — Knowledge Governance & Discipline (Phase 3)
# ============================================================
require_relative "eligibility/knowledge_eligibility_gate"
require_relative "adapter/pdf_document_adapter"
require_relative "grounding/grounded_explanation_controller"

# v0.9.0 — Guided Explanation Layer
require_relative "explanation_builder"

# v0.10.0 — contextual follow‑up Layer
require_relative "follow_up_classifier"
require_relative "boundary_responder"
require_relative "projection_resolver"

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
# ============================================================
def determine_blocking(context)
  focus  = context.current_focus
  status = context.file_state[:status]

  blocking = { is_blocked: false, reason: nil, responsibility: :NONE }

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
# v0.9.0 — Authoritative Response Guardrail
# ============================================================
def authoritative_response?(result)
  return false unless result.is_a?(Hash)
  return true if result.key?(:concept_type)
  return true if result.keys.any? { |k| k.is_a?(String) }
  false
end

# ============================================================
# AI boundary setup
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

# v0.9.0 — Tracks whether an authoritative response
authoritative_response_seen = false

# v0.10.0 — Session‑Persistent Contextual Explanation (Option A)
session_contextual_explanation = nil

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
      file_state = { status: "MAPPING_ERROR", status_category: "ERROR" }

      base_context = AnalysisContext.new(
        session_id: SecureRandom.uuid,
        subject: { type: "payment_file", id: "PF-123" },
        file_state: file_state,
        current_focus: focus,
        reasoning_budget: reasoning_budget,
        lifecycle: { state: lifecycle_state, created_at: Time.now },
        blocking_condition: nil
      )

      context = AnalysisContext.new(
        **base_context.to_h,
        blocking_condition: determine_blocking(base_context)
      )

      # Inject v0.10 session‑persistent explanation into context
      context.contextual_explanation = session_contextual_explanation

      eligibility =
        KnowledgeEligibilityGate.evaluate(
          intent: context.current_focus,
          domain: :reconciliation
        )

      result = nil

      # ------------------------------------------------------
      # Phase 7.0 — Grounded vs Ungrounded Execution
      # SINGLE EXECUTION FORK
      #
      # IMPORTANT:
      # System lifecycle statuses (e.g., PARTIAL RECONCILED, FULL RECONCILED)
      # are authoritative system states and MUST bypass grounding.
      # ------------------------------------------------------
      if eligibility.allowed?

        resolver = IntentResolver.new
        intent = resolver.resolve(input)

        if intent
          explanation = ExplanationBuilder.new.explain(intent.term)

          if explanation
            # v0.9 / v0.10 — system‑state explanation
            session_contextual_explanation = explanation
            context.contextual_explanation = explanation
            result = explanation.to_h
          else
            # v0.7 — handbook‑backed grounding
            result =
              grounded_controller.explain(
                context: context,
                eligibility: eligibility,
                source: intent.source,
                section: intent.section,
                version: intent.version,
                term: intent.term,
                system_prompt: BASE_SYSTEM_PROMPT,
                user_prompt: input
              )
          end

          authoritative_response_seen ||= authoritative_response?(result)
        end
      end

      # ------------------------------------------------------
      # v0.10.0 — Contextual Follow‑Up Reuse (READ‑ONLY)
      # ------------------------------------------------------
      if result.nil? && context.contextual_explanation
        classifier = FollowUpClassifier.new
        classification = classifier.classify(input)

        result =
          case classification
          when :out_of_scope
            BoundaryResponder.new.respond
          when :unknown
            nil
          else
            ProjectionResolver.new.resolve(
              classification,
              context.contextual_explanation
            )
          end
      end

      # ------------------------------------------------------
      # FINAL FALLBACK — Conversational AI (LAST RESORT ONLY)
      # ------------------------------------------------------
      result ||= ai.explain(
        system_prompt: BASE_SYSTEM_PROMPT,
        user_prompt: input
      )

      reasoning_budget[:turns_remaining] -= 1

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