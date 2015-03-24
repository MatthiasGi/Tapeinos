# Holds common design elements that are repeated very often.

module DesignHelper

  include Bh::Helpers

  # ============================================================================

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

  # Outputs a message, if the corresponding flash-attribute is set.
  def flash_message(title, context: nil, text: t(".#{title}"))
    alert_box text, context: context if flash[title]
  end

  # If multiple flash-messages (see above) are checked, this method allows easy
  #    check of multiple messages.
  def flash_messages(*messages)
    output = []
    messages.each do |message|
      output << flash_message(*message)
    end
    safe_join(output)
  end

  # Creates an icon for the corresponding, database-saved rank of a server.
  def rank_icon(rank)
    icons = { novice: :pawn, disciple: :bishop, veteran: :tower, master: :king }
    icon icons[rank.to_sym]
  end

  # Creates an icon for the corresponding, database-saved state of a message.
  def state_icon(state)
    icons = { draft: :edit, sent: :check }
    icon icons[state.to_sym]
  end

  # This helper prints a beautiful representation of the span between two dates.
  # It dry's up the year- and month-overhead, if not needed.
  # E.g. 03.06.2014 – 07.06.2014 becomes 03. – 07.06.2014
  def date_range(start_date, end_date)
    start_format = :incl_day
    start_format = :incl_month unless start_date.month == end_date.month
    start_format = :incl_year unless start_date.year == end_date.year
    [l(start_date, format: start_format), l(end_date)].join(' – ')
  end

end
