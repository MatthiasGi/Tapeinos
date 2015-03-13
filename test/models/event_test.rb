require 'test_helper'

class EventTest < ActiveSupport::TestCase

  def setup
    @plan = { plan: plans(:empty) }
    @date = { date: DateTime.now }
    @all = { **@plan, **@date }
  end

  test "Date and plan necessary" do
    event = Event.new(**@plan)
    assert_not event.valid?, "No date given"
    event = Event.new(**@date)
    assert_not event.valid?, "No plan given"
    event = Event.new(**@all)
    assert event.valid?, "Everything mandatory given"
  end

  test "Needed servers is >0" do
    event = Event.new(**@all, needed: 0)
    assert_not event.valid?, "Needed is = 0, not > 0"
    event.needed = -1
    assert_not event.valid?, "Needed is negative, not > 0"
    event.needed = 2.5
    assert_not event.valid?, "Needed is not an integer"
    event.needed = 1
    assert event.valid?
  end

end
