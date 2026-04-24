# frozen_string_literal: true

# ExplanationBuilder
#
# v0.9.0 — Guided Status & Error Workflows
#
# PURPOSE:
# Orchestrates the process of converting a grounded term
# into a structured, human-usable explanation.
#
# EXECUTION FLOW:
# 1. Receive canonical term (already grounded)
# 2. Classify concept type
# 3. Select appropriate explanation template
# 4. Produce ExplanationContract
#
# IMPORTANT:
# - This class does NOT inspect documents
# - This class does NOT parse user input
# - This class does NOT decide eligibility
#
# It strictly operates AFTER v0.7 and v0.8.

require_relative 'concept_classifier'
require_relative 'templates/mapping_error_template'
require_relative "templates/status_template"
require_relative "templates/terminal_status_template"

class ExplanationBuilder
  def initialize
    @classifier = ConceptClassifier.new
  end

  def explain(term)
    classification = @classifier.classify(term)
    return nil unless classification

    case classification[:concept_type]
    when :error_mapping
      MappingErrorTemplate.new.build(term, classification)

    # Future v0.9.x:
    when :status_blocking
      StatusTemplate.new.build(term, classification)
    when :status_terminal
      TerminalStatusTemplate.new.build(term, classification)
    else
      # Concept supported by grounding but not yet
      # explained in v0.9
      nil
    end
  end
end
