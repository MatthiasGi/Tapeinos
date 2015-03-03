# Holds common design elements that are repeated very often.

module DesignHelper

  # The page-header contains a title and optional subtitle.
  def page_header(title = t('.title'), remark = nil)
    content_tag :div, class: 'page-header' do
      content_tag :h1 do
        html = title.html_safe
        html << ' ' << content_tag(:small, remark) if remark.present?
        html
      end
    end
  end

end
