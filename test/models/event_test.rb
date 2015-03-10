require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "Date and plan necessary" do
    plan = { plan: plans(:plan1) }
    date = { date: DateTime.now }

    event = Event.new(**plan)
    assert_not event.valid?, "No date given"
    event = Event.new(**date)
    assert_not event.valid?, "No plan given"
    event = Event.new(**plan, **date)
    assert event.valid?, "Everything mandatory given"
  end

end
