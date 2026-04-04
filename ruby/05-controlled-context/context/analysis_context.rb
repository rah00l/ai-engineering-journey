# context/analysis_context.rb

class AnalysisContext
  attr_reader :session_id,
              :subject,
              :file_state,
              :system_invariants,
              :reasoning_budget,
              :lifecycle

  def initialize(
    session_id:,
    subject:,
    file_state:,
    system_invariants:,
    reasoning_budget:,
    lifecycle:
  )
    @session_id = session_id
    @subject = subject
    @file_state = file_state
    @system_invariants = system_invariants
    @reasoning_budget = reasoning_budget
    @lifecycle = lifecycle
  end

  # Serialize as a stable, explicit hash
  # This is what will be injected into the AI call later
  def to_h
    {
      session_id: @session_id,
      subject: @subject,
      file_state: @file_state,
      system_invariants: @system_invariants,
      reasoning_budget: @reasoning_budget,
      lifecycle: @lifecycle
    }
  end
end