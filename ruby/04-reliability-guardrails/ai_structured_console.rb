# ai_structured_system_console.rb

require "json"

require_relative "ai_call_boundary"
require_relative "failure_classification"
require_relative "retry_policy"
require_relative "latency_budget"
require_relative "cost_guard"
require_relative "safety_fallback"
require_relative "trust_contract"

api_key = ENV["OPENAI_API_KEY"]
model   = ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")

ai = AiCallBoundary.new(
  api_key: api_key,
  model: model
)

SYSTEM_PROMPT = <<~PROMPT
  You are an AI analyst assistant for a payment reconciliation system.
  Return responses strictly in JSON.
PROMPT

puts "Enter your question (or type 'exit'):"

while (input = STDIN.gets&.strip)
  break if input.downcase == "exit"

  LatencyBudget.start!
  CostGuard.start!

  attempt = 0
  failure = nil

  loop do
    begin
      CostGuard.record!

      result = ai.explain(
        system_prompt: SYSTEM_PROMPT,
        user_prompt: input
      )

      puts JSON.pretty_generate(
        TrustContract.success(result)
      )
      break

    rescue => e
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

  if failure
    fallback = SafetyFallback.build(failure)
    puts JSON.pretty_generate(
      TrustContract.failure(fallback)
    )
  end

  puts "\nEnter another question:"
end
