# frozen_string_literal: true

require_relative "document_adapter"
require "open3"

# PdfDocumentAdapter reads approved sections from a PDF file.
#
# This implementation is deliberately conservative:
# - Uses external pdftotext
# - Extracts text deterministically
# - Performs simple section slicing
#
# Phase: v0.7.0
class PdfDocumentAdapter < DocumentAdapter
  SECTION_HEADERS = {
    definitions: /definitions/i,
    policy: /policy|rules/i,
    status_codes: /status codes?/i
  }

  def fetch_section(source_pointer:, section:, version:)
    pdf_path = resolve_pdf(source_pointer, version)
    return nil unless File.exist?(pdf_path)

    text = extract_text(pdf_path)
    extract_section(text, section)
  end

  private

  def resolve_pdf(source_pointer, version)
    # Example: map pointer → file location
    # You can later replace this with config or registry lookup
    "docs/#{source_pointer}-#{version}.pdf"
  end

  def extract_text(pdf_path)
    stdout, _stderr, _status =
      Open3.capture3("pdftotext", pdf_path, "-")

    stdout
  rescue
    nil
  end

  def extract_section(text, section)
    return nil if text.nil?

    header = SECTION_HEADERS[section]
    return nil unless header

    sections = text.split(/\n{2,}/)

    matched = sections.find { |block| block.match?(header) }

    matched&.strip
  end
end