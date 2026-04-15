# frozen_string_literal: true

# Coordinates grounded explanation execution.
#
# Phase 2:
#  - Decides if system may answer
#
# Phase 3:
#  - Decides if knowledge may be consulted (v0.6.1)
#  - Executes document access (v0.7.0)
#
class GroundedExplanationController
  def initialize(document_adapter:, ai:)
    @document_adapter = document_adapter
    @ai = ai
  end

  def explain(context:, eligibility:, source:, section:, version:, system_prompt:, user_prompt:)
    return explain_without_docs(system_prompt, user_prompt) unless eligibility.allowed?

    content =
      @document_adapter.fetch_section(
        source_pointer: source,
        section: section,
        version: version
      )

    return not_defined_response unless content

    grounded_prompt = <<~PROMPT
      #{system_prompt}

      Use ONLY the following authoritative excerpt.
      Do not add assumptions or external knowledge.

      ---
      #{content}
      ---
    PROMPT

    @ai.explain(
      system_prompt: grounded_prompt,
      user_prompt: user_prompt
    )
  end

  private

  def explain_without_docs(system_prompt, user_prompt)
    @ai.explain(
      system_prompt: system_prompt,
      user_prompt: user_prompt
    )
  end

  def not_defined_response
    {
      status: "NOT_DEFINED",
      message: "This information is not defined in the authoritative documentation."
    }
  end
end