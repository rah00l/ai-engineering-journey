class AnalysisContext
  attr_reader :session_id,
              :subject,
              :file_state,
              :current_focus,
              :reasoning_budget,
              :lifecycle

  def initialize(
    session_id:,
    subject:,
    file_state:,
    current_focus:,
    reasoning_budget:,
    lifecycle:
  )
    @session_id = session_id
    @subject = subject
    @file_state = file_state
    @current_focus = current_focus
    @reasoning_budget = reasoning_budget
    @lifecycle = lifecycle
  end

  def to_h
    {
      session_id: @session_id,
      subject: @subject,
      file_state: @file_state,
      current_focus: @current_focus,
      reasoning_budget: @reasoning_budget,
      lifecycle: @lifecycle
    }
  end
end
