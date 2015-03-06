require 'test_helper'

class PlansControllerTest < ActionController::TestCase

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

end
