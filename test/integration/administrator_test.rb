require 'test_helper'

class AdministratorTest < ActionDispatch::IntegrationTest

  test "No menu-item for non-administrators" do
    user = users(:max)
    post_via_redirect login_path, { user: { email: user.email, password: 'testen' }}
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', false
  end

  test "Menu-item for administrators" do
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', I18n.t('defaults.administration')
  end

  test "Administrative layout on administration" do
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}
    get_via_redirect admin_servers_path
    assert_template 'layouts/administration'
  end

  test "Non-administrative layout for login" do
    get_via_redirect admin_plans_path
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
    post_via_redirect login_path, { user: { email: user.email, password: 'testen' }}
    assert_template 'plans/index'
    assert_equal assigns(:current_server).siblings, assigns(:other_servers)
  end

  test "admin is allowed to change to other servers" do
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}

    server = servers(:heinz)
    last_used = server.last_used
    get_via_redirect change_server_path(server.id), {}, { HTTP_REFERER: admin_servers_path }
    assert_template 'plans/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get_via_redirect plans_path
    assert_equal last_used, Server.find(server.id).last_used # Should not change by simulation
    assert_equal user.servers.to_a, assigns(:other_servers)
    assert_select '.dropdown-menu li', user.servers.count + 4

    # Reselect
    get_via_redirect change_server_path(server.id), {}, { HTTP_REFERER: admin_servers_path }
    assert_template 'plans/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get_via_redirect plans_path
    assert_equal last_used, Server.find(server.id).last_used # Should not change by simulation
    assert_equal user.servers.to_a, assigns(:other_servers)
    assert_select '.dropdown-menu li', user.servers.count + 4

    # Change back
    server = Server.find(user.servers.first.id)
    last_used = server.last_used
    get_via_redirect change_server_path(server.id), {}, { HTTP_REFERER: admin_servers_path }
    assert_template 'admin/servers/index'
    assert_equal server.id, session[:server_id]
    assert_equal server, assigns(:current_server)
    get_via_redirect plans_path
    assert_not_equal last_used, Server.find(server.id).last_used
    assert_equal server.siblings, assigns(:other_servers)
  end

end
