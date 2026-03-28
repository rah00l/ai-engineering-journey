# ai_structured_system_console.rb

require_relative "ai_call_boundary"

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

  response = ai.explain(
    system_prompt: SYSTEM_PROMPT,
    user_prompt: input
  )

  puts "\n=== AI RESPONSE ==="
  puts JSON.pretty_generate(response)
  puts "\nEnter another question:"
end