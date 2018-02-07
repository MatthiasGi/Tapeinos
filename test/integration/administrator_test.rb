require 'test_helper'

class AdministratorTest < ActionDispatch::IntegrationTest

  test "Server can't access anything" do
    server = servers(:heinz)
    get login_seed_path(server.seed)
    follow_redirect!
    get admin_plans_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_servers_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_users_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_messages_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_settings_path
    follow_redirect!
    assert_template 'plans/index'
  end

  test "User can't access administrative interface" do
    user = users(:max)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    get admin_plans_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_servers_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_users_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_messages_path
    follow_redirect!
    assert_template 'plans/index'
    get admin_settings_path
    follow_redirect!
    assert_template 'plans/index'
  end

  test "Admin can't access root-interface" do
    user = users(:admin)
    post login_path, params: { user: { email: user.email, password: 'testtest' }}
    follow_redirect!
    get admin_plans_path
    assert_template 'admin/plans/index'
    get admin_servers_path
    assert_template 'admin/servers/index'
    get admin_users_path
    follow_redirect!
    assert_template 'admin/servers/index'
    get admin_messages_path
    assert_template 'admin/messages/index'
    get admin_settings_path
    follow_redirect!
    assert_template 'admin/servers/index'
  end

  test "Root can access everything" do
    user = users(:root)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    get admin_plans_path
    assert_template 'admin/plans/index'
    get admin_servers_path
    assert_template 'admin/servers/index'
    get admin_users_path
    assert_template 'admin/users/index'
    get admin_messages_path
    assert_template 'admin/messages/index'
    get admin_settings_path
    assert_template 'admin/settings/index'
  end

  test "No menu-item for non-administrators" do
    user = users(:max)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', false
  end

  test "Menu-item for administrators" do
    user = users(:admin)
    post login_path, params: { user: { email: user.email, password: 'testtest' }}
    follow_redirect!
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', I18n.t('defaults.administration')
  end

  test "Administrative layout on administration" do
    user = users(:admin)
    post login_path, params: { user: { email: user.email, password: 'testtest' }}
    follow_redirect!
    get admin_servers_path
    assert_template 'layouts/administration'
  end

  test "Non-administrative layout for login" do
    get admin_plans_path
    assert_template 'sessions/new'
    assert_template layout: 'layouts/application'
  end

  test "Automatically launch setup on accessing any path" do
    User.destroy_all
    get login_path
    assert_redirected_to setup_path(:authenticate)
  end

  test "other servers saved in array" do
    user = users(:max)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    assert_template 'plans/index'
    assert_equal assigns(:current_server).siblings, assigns(:other_servers)
  end

  test "admin is allowed to change to other servers" do
    user = users(:admin)
    post login_path, params: { user: { email: user.email, password: 'testtest' }}
    follow_redirect!
    _simulation_test(user)
  end

  def _simulation_test(user)
    server = servers(:heinz)
    last_used = server.last_used
    get change_server_path(server.id), headers: { HTTP_REFERER: admin_servers_path }
    follow_redirect!
    assert_template 'plans/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get plans_path
    assert_equal last_used, Server.find(server.id).last_used # Should not change by simulation
    assert_equal user.servers.to_a, assigns(:other_servers)
    assert_select '.dropdown-menu li', user.servers.count + 4

    # Reselect
    get change_server_path(server.id), headers: { HTTP_REFERER: admin_servers_path }
    follow_redirect!
    assert_template 'plans/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get plans_path
    assert_equal last_used, Server.find(server.id).last_used # Should not change by simulation
    assert_equal user.servers.to_a, assigns(:other_servers)
    assert_select '.dropdown-menu li', user.servers.count + 4

    # Change back
    server = Server.find(user.servers.first.id)
    last_used = server.last_used
    get change_server_path(server.id), headers: { HTTP_REFERER: admin_servers_path }
    follow_redirect!
    assert_template 'admin/servers/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get plans_path
    assert_not_equal last_used, Server.find(server.id).last_used
    assert_equal server.siblings, assigns(:other_servers)
  end

  test "Also root is allowed to simulate servers" do
    user = users(:root)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!
    _simulation_test(user)
  end

end
