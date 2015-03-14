require 'test_helper'

class Admin::ServersControllerTest < ActionController::TestCase

  def setup
    user = users(:admin)
    @session = { user_id: user.id, server_id: user.servers.first.id }
  end

  test "user must be logged in" do
    get :index, nil, nil
    assert_response :success
    assert_template 'sessions/new'
  end

  test "user and server must be admin" do
    user = users(:max)
    get :index, nil, { user_id: user.id, server_id: user.servers.first.id }
    assert_redirected_to root_path
  end

  test "user must be logged in, not only server" do
    server = servers(:max)
    get :index, nil, { server_id: server.id }
    assert_redirected_to root_path
  end

  test "index shows to administrators" do
    user = users(:admin)
    get :index, nil, @session
    assert_response :success
    assert_template :index
    assert_equal Server.all, assigns(:servers)
  end

end
