# Holds common design elements that are repeated very often.

module DesignHelper

  include Bh::Helpers

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

  def flash_message(title, context: nil, text: t(".#{title}"))
    alert_box text, context: context if flash[title]
  end

  def flash_messages(*messages)
    output = []
    messages.each do |message|
      output << flash_message(*message)
    end
    safe_join(output)
  end

end
