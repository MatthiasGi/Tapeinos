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

  test "Can enroll many servers to an event" do
    servs = [ servers(:heinz), servers(:heinz2), servers(:kunz), servers(:max) ]
    event = events(:easter)
    assert_equal 0, event.enrolled
    assert event.update(servers: servs)
    assert event.valid?
    assert_equal servs, event.servers.reload
    assert_equal 4, event.enrolled
  end

  test "List enrolled servers with short names" do
    shortnames = {
      max: 'Max Mustermann',
      heinz: 'Heinz',
      kunz: 'Kunz Hinz',
      admin: 'Admin',
      shortkunz: 'Kunz Hind.',
      shortmax: 'Max S.',
      maxcopy: 'Max Mustermann'
    }
    event = events(:easter)

    servs = []
    names = []
    shortnames.each do |key, value|
      servs << servers(key)
      names << value
    end

    assert event.update(servers: servs)
    assert_equal names.sort.join(', '), event.list_servers
  end

end
