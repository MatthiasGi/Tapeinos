require 'test_helper'

class AdminWithoutServersTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:admin_without_servers)
    @user_server = users(:admin)
    @root_server = users(:root)
  end

  def layout_test
    assert_select '.btn-group.pull-right' do
      assert_select 'li', 3
    end

    assert_select 'ul.navbar-nav' do
      assert_select 'li', 1
    end
  end

  def layout_test_server
    assert_select '.btn-group.pull-right' do
      assert_select 'li', 5
    end

    assert_select 'ul.navbar-nav' do
      assert_select 'li', 2
    end
  end

  def login
    get logout_path
    post login_path, params: { user: { email: @user.email, password: 'testen' }}
    follow_redirect!
  end

  def login_server
    get logout_path
    post login_path, params: { user: { email: @user_server.email, password: 'testtest' }}
    follow_redirect!
  end

  def login_root_server
    get logout_path
    post login_path, params: { user: { email: @root_server.email, password: 'testen' }}
    follow_redirect!
  end

  test "Gets redirected to servers overview" do
    login
    assert_template 'admin/servers/index'

    login_server
    assert_template 'plans/index'
  end

  test "Has settings menu in menubar" do
    login
    assert_select '.btn-group.pull-right' do
      assert_select 'li', 3
    end

    login_server
    assert_select '.btn-group.pull-right' do
      assert_select 'li', 4 + @user_server.servers.count - 1
    end
  end

  test "Has no other entries in menubar" do
    login
    assert_select 'ul.navbar-nav' do
      assert_select 'li', 1
    end

    login_server
    assert_select 'ul.navbar-nav' do
      assert_select 'li', 2
    end
  end

  test "Sees reduced settings for his user" do
    login
    get settings_path
    assert_template 'users/edit'
    assert_select 'h2', 1 # Only one section-header (no servers-section)

    login_server
    get settings_path
    assert_template 'users/edit'
    assert_select 'h2', 2
  end

  test "Gets redirected to administrative root on invalid route" do
    login
    get plans_path
    follow_redirect!
    assert_template 'admin/servers/index'
  end

  test "removing all servers from current user updates views" do
    login_root_server
    assert @root_server.reload.servers.any?
    patch admin_user_path(@root_server), params: { user: { server_ids: [ nil ] }}
    follow_redirect!
    assert @root_server.reload.servers.empty?

    layout_test
  end

  test "removing last server from current user updates views" do
    servers = @root_server.servers
    server = servers.first
    @root_server.servers = [ server ]
    @root_server.save
    login_root_server

    patch admin_server_path(server), params: { server: { user_id: nil }}
    follow_redirect!
    assert @root_server.reload.servers.empty?

    layout_test
  end

  test "deleting last server from current user updates views" do
    servers = @user_server.servers
    server = servers.first
    @user_server.servers = [ server ]
    @user_server.save
    login_server

    delete admin_server_path(server)
    follow_redirect!
    layout_test
  end

  test "adding server to user should update views" do
    @user_server.servers = []
    @user_server.save
    login_server

    assert @user_server.reload.servers.empty?
    patch admin_server_path(Server.first), params: { server: { user_id: @user_server.id }}
    follow_redirect!
    patch admin_server_path(Server.second), params: { server: { user_id: @user_server.id }}
    follow_redirect!
    assert @user_server.reload.servers.any?

    layout_test_server
  end

  test "user adding server list should update views" do
    @root_server.servers = []
    @root_server.save
    login_root_server

    assert @root_server.reload.servers.empty?
    patch admin_server_path(Server.first), params: { server: { user_id: @root_server.id }}
    follow_redirect!
    patch admin_server_path(Server.second), params: { server: { user_id: @root_server.id }}
    follow_redirect!
    assert @root_server.reload.servers.any?

    layout_test_server
  end

  test "removing current server of current user" do
    login_server
    server = assigns(:current_server)
    servers = @user_server.servers.without(server)

    patch admin_server_path(server), params: { server: { user_id: nil }}
    follow_redirect!
    assert_equal servers, @user_server.reload.servers
    assert_equal servers.first, assigns(:current_server)
  end

end
