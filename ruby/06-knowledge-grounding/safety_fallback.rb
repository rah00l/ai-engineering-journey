# safety_fallback.rb

module SafetyFallback
  def self.build(reason)
    {
      status: "FAILURE",
      reason: reason,
      message: "Request terminated safely"
    }
  end
end