module RegistrationHelper
  def reg_title(step_title = '')
    base_title = "LYF Camp #{@camp.year} Registration"
    base_title.empty? ? base_title : "#{step_title} | #{base_title}"
  end
end
