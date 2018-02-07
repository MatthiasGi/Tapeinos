require 'test_helper'

class PlanTest < ActiveSupport::TestCase

  test "Title is mandatory" do
    plan = Plan.new(remark: 'Blabla')
    assert_not plan.valid?, "No title given"

    plan = Plan.new(title: 'Title')
    assert plan.valid?, "Title given, but still wrong?"
  end

  test "Linked to events" do
    plan = Plan.new(title: 'Title')
    assert plan.save
    events = []
    3.times do
      event = Event.new(date: DateTime.now, plan: plan)
      event.save
      events << event
    end
    assert plan.valid?
    plan = Plan.find(plan.id)
    assert_equal events, plan.events.to_a

    plan.destroy
    assert_not Plan.find_by(id: plan.id)
    events.each { |event| assert_not Event.find_by(id: event.id) }
  end

  test "First and last date" do
    plan = plans(:easter)
    events = plan.events.order(:date)
    assert_equal events.first.date.to_date, plan.first_date
    assert_equal events.last.date.to_date, plan.last_date
  end

  test "To string" do
    plan = plans(:easter)
    assert_equal plan.title, "#{plan}"
  end

  test "nested attributes for events" do
    plan = plans(:easter)
    event = plan.events.first
    assert plan.update(events_attributes: { id: event.id, title: 'test' })
    assert_equal 'test', Event.find(event.id).title
  end

  test "reject invalid nested attributes" do
    plan = plans(:easter)
    event = plan.events.first
    assert_not plan.update(events_attributes: { id: event.id, date: nil })
    assert_not plan.valid?
    assert_not_nil Event.find(event.id).date
  end

  test "create new events" do
    plan = plans(:easter)
    date = DateTime.now
    assert_difference 'Plan.find(plan.id).events.count', +1 do
      assert plan.update(events_attributes: [{ date: date, title: 'test' }])
    end
    assert event = Event.find_by(date: date)
    assert_equal 'test', event.title
  end

  test "reject new if date blank" do
    plan = plans(:easter)
    assert_no_difference 'Plan.find(plan.id).events.count' do
      assert_not plan.update(events_attributes: [{ date: nil }])
    end
  end

  test "delete an event" do
    plan = plans(:easter)
    id = plan.events.first.id
    assert_difference 'Plan.find(plan.id).events.count', -1 do
      assert plan.update(events_attributes: { id: id, _destroy: 1 })
    end
    assert_not Event.find_by(id: id)
  end

  test "Last/First on empty" do
    plan = plans(:empty)
    assert_nil plan.first_date
    assert_nil plan.last_date
  end

  test "Multiple servers can enroll for a plan" do
    plan = plans(:easter)
    servers = Server.all
    assert plan.update(servers: servers)
    assert_equal servers, plan.servers.reload
  end

end
