module ApplicationHelper
  def full_title(title = '')
    base_title = 'LYF Archive'
    title.empty? ? base_title : "#{title} | #{base_title}"
  end
end
