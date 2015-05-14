# Holds common design elements that are repeated very often.

module DesignHelper

  include Bh::Helpers

  # ============================================================================

  # The page-header contains a title and optional subtitle. If a help-text is available, a help-button is displayed that
  #    shows the help text on click.
  def page_header(title = t('.title'), remark = nil, help_text = t('.help', default: ''))
    render partial: 'shared/page_header', locals: { title: title, remark: remark, help_text: help_text }
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
  #    It dries up the year- and month-overhead, if not needed.
  #    E.g. 03.06.2014 – 07.06.2014 becomes 03. – 07.06.2014
  #    The optional format can be set and correspondents to entries in
  #    LANG.daterange.formats.FORMAT
  def date_range(start_date, end_date, format: :default)
    l = "daterange.formats.#{format}"
    formats = [ :day, :month, :year ].map { |f| I18n.t("#{l}.#{f}") }

    start_date.nil? and return locale(end_date, format: formats[2])
    end_date.nil? or start_date == end_date and return locale(start_date, format: formats[2])

    start_format = 0
    start_format = 1 unless start_date.month == end_date.month
    start_format = 2 unless start_date.year == end_date.year

    from = l start_date, format: formats[start_format]
    to = l end_date, format: formats[2]
    I18n.t("#{l}.range") % { from: from, to: to }
  end

  # Localizes a date and displays an empty string if localization is not
  #    possible. Doesn't mess up the UI.
  def locale(date, format = nil)
    l date, format rescue ''
  end

  # Displays a neat progressbar with the number of servers that are already
  #    enrolled for the current plan.
  def enrollement(plan)
    label = [plan.servers.count, Server.count].join(' / ')
    percentage = 100 * plan.servers.count / Server.count
    progress_bar percentage: percentage, label: label,
                 class: ('empty' unless plan.servers.any?)
  end

  # Displays severe server-errors inside one consistent message with preference
  #    for required restarts.
  def server_errors
    conditions = [ :restart_required, :redis_down, :sidekiq_down,
      :sidekiq_mailer_down ]
    errors = conditions.select { |c| SettingsHelper.get(c) }
    errors.empty? and return nil
    errors.include? :restart_required and errors = [ :restart_required ]
    render partial: 'shared/server_errors', locals: { messages: errors }
  end

end
