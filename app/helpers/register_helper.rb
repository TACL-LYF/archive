module RegisterHelper
  def reg_title(step_title = '')
    base_title = 'LYF Camp 2017 Registration'
    base_title.empty? ? base_title : "#{step_title} | #{base_title}"
  end
end
