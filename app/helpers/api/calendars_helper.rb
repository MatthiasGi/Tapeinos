module Api::CalendarsHelper

  def calendar_time(time)
    time.strftime("%Y%m%dT%H%M%SZ")
  end

  def calendar_event(event)
    <<~HEREDOC
      BEGIN:VEVENT
      UID:#{event.id}
      SUMMARY:#{event.title}
      LOCATION:#{event.location}
      DTSTART:#{calendar_time(event.date - 15.minutes)}
      DTEND:#{calendar_time(event.date + 1.hour)}
      STATUS:CONFIRMED
      LAST-MODIFIED:#{calendar_time(event.updated_at)}
      END:VEVENT
    HEREDOC
  end

end
