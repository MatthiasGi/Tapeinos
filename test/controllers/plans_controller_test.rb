require 'test_helper'

class PlansControllerTest < ActionController::TestCase

  def setup
    @session = { server_id: servers(:heinz).id }
  end

  test "only logged in user allowed" do
    get :index, nil, nil
    assert_response :success
    assert_template 'sessions/new'

    user = users(:max)
    get :index, nil, {user_id: user.id, server_id: user.servers.first.id}
    assert_response :success
    assert_template :index
    assert_equal user, assigns(:current_user)
  end

  test "allow logged in server" do
    server = servers(:heinz)
    get :index, nil, {server_id: server.id}
    assert_response :success
    assert_template :index
    assert_equal server, assigns(:current_server)
  end

  test "get register advertising" do
    server = servers(:heinz)
    get :index, nil, { server_id: server.id }
    assert_select '.panel .btn', I18n.t('defaults.register.submit')

    user = users(:max)
    server = user.servers.first
    get :index, nil, { user_id: user.id, server_id: server.id }
    assert_select '.panel .btn', false
  end

  test "listing all plans" do
    get :index, nil, @session
    assert_response :success
    assert_template :index

    expected = Plan.all.find_all{ |p| p.last_date.past? }.sort_by(&:last_date)
    assert_equal expected, assigns(:plans)
  end

end
