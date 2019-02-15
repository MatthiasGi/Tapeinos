require 'test_helper'

class CalendarsHelperTest < ActionView::TestCase
  include Api::CalendarsHelper

  test "display datetime in ical format" do
    time = calendar_time(DateTime.new(2018, 2, 1, 14, 32, 17))
    assert_equal "20180201T143217Z", time
  end

  test "render event" do
    time = DateTime.new(2018, 2, 1, 14, 32, 17)
    event = Event.create(date: time, title: 'Testen', location: 'Location',
        plan: plans(:easter))
    started = calendar_time(event.date - 15.minutes)
    ended = calendar_time(event.date + 1.hour)
    last_modified = calendar_time(event.updated_at)
    expected = "BEGIN:VEVENT\nUID:" + event.id.to_s + "\nSUMMARY:Testen\n"
        + "LOCATION:Location\nDTSTART:" + started + "\nDTEND:" + ended
        + "\nSTATUS:CONFIRMED\nLAST-MODIFIED:" + last_modified
        + "\nEND:VEVENT\n"
    assert_equal expected, calendar_event(event)
  end

end
