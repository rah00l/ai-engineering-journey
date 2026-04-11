# frozen_string_literal: true

# Central registry for all knowledge sources known to the system.
#
# This registry is:
# - Read-only during runtime
# - Global (not session-scoped)
# - Passive (no retrieval, no reasoning)
#
# It is the single source of truth for:
# - What documentation exists
# - What authority it has
# - Which domain it applies to
#
# Phase: v0.6.0
# Responsibility: Governance and inspection ONLY.
class KnowledgeRegistry
  def initialize
    @sources = {}
  end

  # Registers a new knowledge source.
  #
  # Typically called during system initialization.
  # Not expected to be called as part of request handling.
  def register(source)
    @sources[source.id] = source
  end

  # Returns all registered knowledge sources.
  def all_sources
    @sources.values
  end

  # Finds all ACTIVE sources applicable to a given domain.
  def find_by_domain(domain)
    @sources.values.select do |source|
      source.active? && source.domain_scope.include?(domain)
    end
  end

  # Lookup by id (used later for eligibility checks).
  def find_by_id(id)
    @sources[id]
  end
end