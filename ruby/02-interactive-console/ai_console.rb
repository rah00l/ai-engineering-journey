# ai_console.rb

require "httparty"
require "json"

api_key = ENV["OPENAI_API_KEY"]
raise "Missing OPENAI_API_KEY" unless api_key

SYSTEM_PROMPT = <<~PROMPT
  You are an AI assistant for an enterprise payment reconciliation system.

  Your role:
  - Explain reconciliation statuses, errors, and system behavior in business terms
  - Help accounting users understand *why* the system behaves a certain way
  - Describe typical causes and next steps

  Strict boundaries:
  - Do NOT invent transaction-specific details
  - Do NOT assume access to databases
  - Do NOT suggest modifying data
  - If a question requires transactional data, say that system data is required  
	- Do not mention approvals, reviewers, or manual approvals
	- Use tenancy settlement terminology where applicable
	- PARTIALLY RECONCILED specifically refers to incomplete tenancy settlement
	- If unsure, state limitations clearly
	- Do not suggest timing or import delays
	- Do not refer to user data entry
	- Mapping errors are deterministic and block processing
	- Reference aggregator-based payment files
	- Explicitly state when file removal and re-upload is required


  Keep answers concise, accurate, and business-friendly.
PROMPT

def call_ai(api_key, messages)
  response = HTTParty.post(
    "https://api.openai.com/v1/chat/completions",
    headers: {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{api_key}"
    },
    body: {
      model: "gpt-4o-mini",
      messages: messages,
      temperature: 0.3
    }.to_json
  )

  raise "API error #{response.code}: #{response.body}" if response.code != 200

  JSON.parse(response.body)
      .dig("choices", 0, "message", "content")
end

puts "Reconciliation AI Console"
puts "Type ':exit' to quit\n\n"

messages = [{ role: "system", content: SYSTEM_PROMPT }]

loop do
  print "> "
  input = STDIN.gets&.strip
  break if input.nil? || input == ":exit"

  messages << { role: "user", content: input }

  begin
    answer = call_ai(api_key, messages)
    puts "\nAI:\n#{answer}\n\n"
    messages << { role: "assistant", content: answer }
  rescue => e
    puts "\n[Error] #{e.message}\n\n"
  end
end