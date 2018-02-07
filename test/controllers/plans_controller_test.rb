require 'test_helper'

class PlansControllerTest < ActionController::TestCase

  def setup
    @server = servers(:heinz)
    session[:server_id] = @server.id
  end

  test "listing all plans" do
    get :index
    assert_response :success
    assert_template :index

    expected = Plan.all.find_all{ |p| !p.last_date.past? rescue false }.sort_by(&:first_date)
    assert_equal expected, assigns(:plans)
  end

  test "homepage marks new plans for servers" do
    get :index
    number = 0
    assert_select '.label.label-primary', I18n.t('defaults.new') do |obj|
      number = obj.size
    end

    # enroll for a plan
    plan = plans(:easter)
    assert plan.update(servers: [ @server ])

    get :index
    number -= 1
    assert_select '.label.label-primary', number
  end

  test "enrolling for a plan" do
    plan = plans(:easter)
    get :show, params: { id: plan.id }
    assert_response :success
    assert_template :show
    assert_equal plan, assigns(:plan)
  end

  test "saving enrollement" do
    plan = plans(:easter)
    assert_not_includes plan.servers, @server
    evts = [ events(:easter), events(:goodfriday) ]
    ids = evts.map(&:id)
    patch :update, params: { id: plan.id, events: ids }
    assert_response :success
    assert_template :show
    assert_equal evts, @server.events.reload
    evts.each { |event|  assert_includes event.servers.reload, @server }
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
    assert_includes plan.servers, @server
  end

  test "saving with empty plan list" do
    plan = plans(:easter)
    assert_not_includes plan.servers, @server
    patch :update, params: { id: plan.id, events: nil }
    assert_response :success
    assert_template :show
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
    assert_includes plan.servers, @server
  end

  test "saving plan-enrollement only if not already saved" do
    plan = plans(:easter)
    assert_not_includes plan.servers, @server
    patch :update, params: { id: plan.id, events: nil }
    assert_includes plan.servers, @server
    patch :update, params: { id: plan.id, events: nil }
    assert_equal 1, plan.servers.to_a.count(@server)
  end

  test "invalid plan shows overview" do
    get :show, params: { id: 1 }
    assert_redirected_to plans_path

    patch :update, params: { id: 1 }
    assert_redirected_to plans_path
  end

  test "adding to already enrolled events" do
    plan = plans(:easter)
    pres = [ events(:holythursday), events(:older), events(:easter) ]
    posts = [ events(:easter), events(:goodfriday) ]
    events = [ events(:older), events(:easter), events(:goodfriday) ]
    @server.update(events: pres)

    patch :update, params: { id: plan.id, events: posts }
    assert_equal events, @server.events.reload
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
  end

end
