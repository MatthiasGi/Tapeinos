require 'test_helper'

class PlansControllerTest < ActionController::TestCase

  def setup
    @server = servers(:heinz)
    @session = { server_id: @server.id }
  end

  test "only logged in user allowed" do
    get :index, nil, nil
    assert_response :success
    assert_template 'sessions/new'

    user = users(:max)
    get :index, nil, { user_id: user.id, server_id: user.servers.first.id }
    assert_response :success
    assert_template :index
    assert_equal user, assigns(:current_user)
  end

  test "allow logged in server" do
    server = servers(:heinz)
    get :index, nil, @session
    assert_response :success
    assert_template :index
    assert_equal server, assigns(:current_server)
  end

  test "listing all plans" do
    get :index, nil, @session
    assert_response :success
    assert_template :index

    expected = Plan.all.find_all{ |p| !p.last_date.past? rescue false }.sort_by(&:first_date)
    assert_equal expected, assigns(:plans)
  end

  test "enrolling for a plan" do
    plan = plans(:easter)
    get :show, { id: plan.id }, @session
    assert_response :success
    assert_template :show
    assert_equal plan, assigns(:plan)
  end

  test "saving enrollement" do
    plan = plans(:easter)
    evts = [ events(:easter), events(:goodfriday) ]
    ids = evts.map(&:id)
    patch :update, { id: plan.id, events: ids }, @session
    assert_response :success
    assert_template :show
    assert_equal evts, @server.events(true)
    evts.each { |event|  assert_includes event.servers(true), @server }
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
  end

  test "saving with empty plan list" do
    plan = plans(:easter)
    patch :update, { id: plan.id, events: nil }, @session
    assert_response :success
    assert_template :show
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
  end

  test "invalid plan shows overview" do
    get :show, { id: 1 }, @session
    assert_redirected_to plans_path

    patch :update, { id: 1 }, @session
    assert_redirected_to plans_path
  end

  test "adding to already enrolled events" do
    plan = plans(:easter)
    pres = [ events(:holythursday), events(:older), events(:easter) ]
    posts = [ events(:easter), events(:goodfriday) ]
    events = [ events(:older), events(:easter), events(:goodfriday) ]
    @server.update(events: pres)

    patch :update, { id: plan.id, events: posts }, @session
    assert_equal events, @server.events(true)
    assert_select '.alert.alert-success', I18n.t('plans.show.enrolled')
  end

end
