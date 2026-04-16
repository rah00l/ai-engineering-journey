# frozen_string_literal: true

require_relative "document_adapter"

# PdfDocumentAdapter
#
# Concrete execution adapter for PDF-based documentation.
#
# v0.7.0 responsibility:
# - Exist as a concrete adapter implementation
# - Be invoked when knowledge usage is permitted
# - Return a deterministic execution result
#
# IMPORTANT:
# - This version DOES NOT read files
# - This version DOES NOT parse PDFs
# - Returning nil is a valid and expected outcome
#
# Later milestones will extend this adapter incrementally:
# - v0.7.1: Source pointer resolution (file existence)
# - v0.7.2: Section identification (definitions, policies)
# - v0.7.3: Term-level grounded extraction
#
# Phase: v0.7.0
# Responsibility: Execution plumbing only
class PdfDocumentAdapter < DocumentAdapter
  # Attempts to fetch an approved document section.
  #
  # @param source_pointer [String] Stable reference to the document
  # @param section [Symbol] Logical section (e.g. :definitions)
  # @param version [String] Document version identifier
  #
  # @return [String, nil]
  #   nil indicates that no authoritative content is available
  def fetch_section(source_pointer:, section:, version:)
    document_path = resolve_source_pointer(source_pointer, version)

    return nil unless File.exist?(document_path)

    # v0.7.0 intentionally performs no document access.
    # This validates execution wiring without enabling retrieval.
    nil
  end

  private
  # Resolves a stable document identifier into a concrete file path.
  #
  # NOTE:
  # - Resolution logic is deterministic
  # - No file parsing occurs here
  def resolve_source_pointer(source_pointer, version)
    File.join(File::SEPARATOR, "docs", "#{source_pointer}-#{version}.pdf")
  end
end
