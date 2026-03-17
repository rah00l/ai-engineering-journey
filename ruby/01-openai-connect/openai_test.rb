# openai_test.rb

require "httparty"
require "json"

api_key = ENV["OPENAI_API_KEY"]
raise "Missing OPENAI_API_KEY" unless api_key

url = "https://api.openai.com/v1/chat/completions"

headers = {
  "Content-Type" => "application/json",
  "Authorization" => "Bearer #{api_key}"
}

body = {
  model: "gpt-4o-mini",
  messages: [
    { role: "system", content: "You are a concise assistant." },
    { role: "user", content: "Explain AI engineering in one sentence." }
  ],
  temperature: 0.3
}

response = HTTParty.post(
  url,
  headers: headers,
  body: body.to_json
)

if response.code != 200
  puts "HTTP #{response.code}"
  puts response.body
  exit 1
end

data = JSON.parse(response.body)
puts data["choices"][0]["message"]["content"]