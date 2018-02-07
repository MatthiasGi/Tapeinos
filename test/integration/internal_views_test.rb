require 'test_helper'

class InternalViewsTest < ActionDispatch::IntegrationTest

  test "Only logged in user allowed for plans" do
    get plans_path
    assert_response :success
    assert_template 'sessions/new'

    user = users(:max)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    assert_template 'plans/index'
    assert_equal user.servers.first, assigns(:current_server)
    assert_equal user, assigns(:current_user)
  end

  test "allow logged in server" do
    server = servers(:heinz)
    get login_seed_path(server.seed)
    follow_redirect!
    assert_template 'plans/index'
    assert_equal server, assigns(:current_server)
    assert_nil assigns(:current_user)
  end

end
