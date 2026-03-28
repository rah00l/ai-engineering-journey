# ai_call_boundary.rb

require "json"
require "net/http"
require "uri"

class AiCallBoundary
  OPENAI_ENDPOINT = "https://api.openai.com/v1/chat/completions"

  def initialize(api_key:, model:)
    raise ArgumentError, "API key is required" unless api_key
    raise ArgumentError, "Model is required" unless model

    @api_key = api_key
    @model = model
  end

  # Public contract:
  # Always returns a normalized result hash.
  # Never raises raw OpenAI or network exceptions upward.
  def explain(system_prompt:, user_prompt:)
    raw_response = perform_api_call(system_prompt, user_prompt)
    normalize_response(raw_response)

  rescue StandardError => e
    # NOTE: This is a *technical failure fallback*.
    # Retry logic will be added in later steps.
    {
      status: :technical_failure,
      error: "AI call failed",
      details: e.message
    }
  end

  private

  def perform_api_call(system_prompt, user_prompt)
    uri = URI.parse(OPENAI_ENDPOINT)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@api_key}"

    request.body = {
      model: @model,
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: user_prompt }
      ],
      temperature: 0.0
    }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise "OpenAI API error: #{response.code} #{response.message}"
    end

    JSON.parse(response.body)
  end

  def normalize_response(raw_response)
    # Defensive checks
    content = raw_response.dig("choices", 0, "message", "content")
    raise "Empty response from AI" unless content

    parsed_json = JSON.parse(content)

    if parsed_json.is_a?(Hash) && parsed_json[:error] == "INSUFFICIENT_CONTEXT"
      {
        status: :logical_refusal,
        result: parsed_json
      }
    else
      {
        status: :success,
        result: parsed_json
      }
    end

  rescue JSON::ParserError
    {
      status: :invalid_output,
      error: "AI returned invalid JSON"
    }
  end
end