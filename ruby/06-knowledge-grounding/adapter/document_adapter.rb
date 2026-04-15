# frozen_string_literal: true

# DocumentAdapter defines the contract for all document access.
#
# This interface is intentionally minimal and deterministic.
# All implementations must:
#  - Fetch only approved sections
#  - Return plain text or nil
#  - Never infer relevance
#  - Never cache or persist content
#
# Phase: v0.7.0
class DocumentAdapter
  # @param source_pointer [String]
  # @param section [Symbol]
  # @param version [String]
  #
  # @return [String, nil]
  def fetch_section(source_pointer:, section:, version:)
    raise NotImplementedError, "Implement in subclass"
  end
end