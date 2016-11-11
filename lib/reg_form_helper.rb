module RegFormHelper
  def required_for_step?(step)
    return true if reg_step.nil?
    return true if self.reg_steps.index(step.to_s) <= self.reg_steps.index(reg_step)
  end
end
