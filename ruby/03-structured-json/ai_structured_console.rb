# ai_structured_console.rb

require "httparty"
require "json"

SYSTEM_PROMPT = <<~PROMPT
You are an AI assistant for an enterprise payment reconciliation system.

Your task is to explain reconciliation concepts using a STRICT JSON format.

Rules:
- You MUST respond ONLY with valid JSON.
- Do NOT include markdown, comments, or extra text.
- Do NOT invent workflows such as approvals or timing delays.
- Use only reconciliation terminology.
- If transaction-specific data is required, state it explicitly.

Allowed user actions:
- NONE
- REUPLOAD_REQUIRED
- TENANCY_SETTLEMENT_REQUIRED
- CONTACT_SUPPORT

Data dependency values:
- NONE
- DOCUMENT_ONLY
- TRANSACTION_DATA_REQUIRED

If you cannot confidently fill all JSON fields, return:
{
  "error": "INSUFFICIENT_CONTEXT"
}
PROMPT

api_key = ENV["OPENAI_API_KEY"]
raise "Missing OPENAI_API_KEY" unless api_key

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
      temperature: 0.2
    }.to_json
  )

  raise "API error #{response.code}" if response.code != 200

  content = JSON.parse(response.body)
                .dig("choices", 0, "message", "content")

  JSON.parse(content)
rescue JSON::ParserError
  { "error" => "INVALID_JSON_RESPONSE" }
end

puts "Structured Reconciliation AI Console (:exit to quit)\n\n"

messages = [{ role: "system", content: SYSTEM_PROMPT }]

loop do
  print "> "
  input = STDIN.gets&.strip
  break if input.nil? || input == ":exit"

  messages << { role: "user", content: input }

  result = call_ai(api_key, messages)
  pp result
  puts

  # messages << { role: "assistant", content: result.to_json }
  messages.pop
end