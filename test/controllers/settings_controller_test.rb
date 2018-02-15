require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!

  def setup
    @user = users(:max)
    @server = servers(:heinz)
    @admin = users(:admin_without_servers)
    @root = users(:root)
  end

  def logout
    get logout_path
  end

  def login_user
    logout
    post login_path, params: { user: { email: @user.email, password: 'testen' }}
  end

  def login_server
    logout
    get login_seed_path(seed: @server.seed)
  end

  def login_admin
    logout
    post login_path, params: { user: { email: @admin.email, password: 'testen' }}
  end

  def login_root
    logout
    post login_path, params: { user: { email: @root.email, password: 'testen' }}
  end


  test "security should be available to server only" do
    get settings_security_path
    assert_template 'sessions/new'

    login_user
    get settings_security_path
    assert_redirected_to settings_path

    login_server
    get settings_security_path
    assert_response :success
    assert_template :security
  end

  test "servers should be available to user and server" do
    get settings_servers_path
    assert_template 'sessions/new'

    login_user
    get settings_servers_path
    assert_response :success
    assert_template :servers

    login_server
    get settings_servers_path
    assert_response :success
    assert_template :servers
  end

  test "delete should be available to user only" do
    get settings_delete_path
    assert_template 'sessions/new'

    login_user
    get settings_delete_path
    assert_response :success
    assert_template :delete

    login_server
    get settings_delete_path
    assert_redirected_to settings_path
  end

  test "root path should be available to user and server" do
    get settings_path
    assert_template 'sessions/new'

    login_user
    get settings_path
    assert_response :success
    assert_template :servers

    login_server
    get settings_path
    assert_response :success
    assert_template :servers
  end

  test "data should be available to user only" do
    get settings_data_path
    assert_template 'sessions/new'

    login_user
    get settings_data_path
    assert_response :success
    assert_template :data

    login_server
    get settings_data_path
    assert_redirected_to settings_path
  end

  test "user without servers gets redirected to data" do
    login_admin
    get settings_path
    assert_redirected_to settings_data_path

    login_admin
    get settings_security_path
    assert_redirected_to settings_data_path

    login_admin
    get settings_servers_path
    assert_redirected_to settings_data_path

    login_admin
    get settings_data_path
    assert_response :success
    assert_template :data

    login_admin
    get settings_delete_path
    assert_response :success
    assert_template :delete
  end

  test "menu items are displayed accordingly" do
    login_user
    get settings_path
    assert_select '.nav-pills' do
      assert_select 'li.active', 1
      assert_select 'a', { text: I18n.t('settings.servers.title'), count: 1 }
      assert_select 'a', { text: I18n.t('settings.data.title'), count: 1 }
      assert_select 'a', { text: I18n.t('settings.security.title'), count: 0 }
      assert_select 'a', { text: I18n.t('settings.delete.title'), count: 1 }
    end

    login_server
    get settings_path
    assert_select '.nav-pills' do
      assert_select 'li.active', 1
      assert_select 'a', { text: I18n.t('settings.servers.title'), count: 1 }
      assert_select 'a', { text: I18n.t('settings.data.title'), count: 0 }
      assert_select 'a', { text: I18n.t('settings.security.title'), count: 1 }
      assert_select 'a', { text: I18n.t('settings.delete.title'), count: 0 }
    end

    login_admin
    get settings_data_path
    assert_select '.nav-pills' do
      assert_select 'li.active', 1
      assert_select 'a', { text: I18n.t('settings.servers.title'), count: 0 }
      assert_select 'a', { text: I18n.t('settings.data.title'), count: 1 }
      assert_select 'a', { text: I18n.t('settings.security.title'), count: 0 }
      assert_select 'a', { text: I18n.t('settings.delete.title'), count: 1 }
    end
  end

  test "data update only available to registered users" do
    post settings_data_path, params: { user: { servers: { '1': nil }}}
    assert_template 'sessions/new'

    login_server
    post settings_data_path, params: { user: { servers: { '1': nil }}}
    assert_redirected_to settings_path

    login_user
    post settings_data_path, params: { user: { servers: { '1': nil }}}
    assert_response :success
    assert_template :data

    login_admin
    post settings_data_path, params: { user: { servers: { '1': nil }}}
    assert_response :success
    assert_template :data
  end

  test "updating user-values with invalid email" do
    login_user
    post settings_data_path, params: { user: { email: 'testen.de' }}
    assert_template :data
    assert_select '.alert.alert-success', false
    assert_not_equal 'testen.de', @user.reload.email
    assert_select '.user_email.has-error .help-block'
  end

  test "updating user-values only with email" do
    login_user
    post settings_data_path, params: { user: { email: 'test@bla.de' }}
    assert_template :data
    assert_select '.alert.alert-success', I18n.t('users.edit.changes_saved')
    assert_equal 'test@bla.de', @user.reload.email
  end

  test "updating user-values only with password" do
    login_user
    post settings_data_path, params: { user: { password: 'testenen', password_confirmation: 'testenen' }}
    assert @user.reload.authenticate('testenen')
    assert_template :data
    assert_select '.alert.alert-success'
  end

  test "updating user-values with wrong confirmation" do
    login_user
    post settings_data_path, params: { user: { password: 'testenen', password_confirmation: 'testenem' }}
    assert_template :data
    assert_select '.alert.alert-success', false
    assert_select '.user_password_confirmation.has-error .help-block'
    assert_not @user.reload.authenticate('testenen') or @user.authenticate('testenem')
  end

  test "updating user-values with invalid password" do
    login_user
    post settings_data_path, params: { user: { password: 'test', password_confirmation: 'test' }}
    assert_template :data
    assert_select '.alert.alert-success', false
    assert_select '.user_password.has-error .help-block'
    assert_not @user.reload.authenticate('test')
  end

  test "access to server-updates only accessible for servers and users with servers" do
    post settings_servers_path, params: { user: { servers: { '1': nil }}}
    assert_template 'sessions/new'

    login_server
    post settings_servers_path, params: { user: { servers: { '1': nil }}}
    assert_response :success
    assert_template :servers

    login_user
    post settings_servers_path, params: { user: { servers: { '1': nil }}}
    assert_response :success
    assert_template :servers

    login_admin
    post settings_servers_path, params: { user: { servers: { '1': nil }}}
    assert_redirected_to settings_data_path
  end

  test "user: requesting sizes" do
    login_user
    get settings_servers_path
    assert_equal @user.servers.map(&:id).sort, assigns(:servers).map(&:id).sort
  end

  test "user: updating valid size for servers" do
    login_user
    server = @user.servers.first
    post settings_servers_path, params: { user: { servers: { server.id => { size_talar: 150, size_rochet: 90 }}}}
    assert_response :success
    assert_template :servers
    assert_equal 150, server.reload.size_talar
    assert_equal 90, server.size_rochet
    assert_select '.alert.alert-success', I18n.t('settings.servers.changes_saved')
    assert_equal @user.servers.map(&:id).sort, assigns(:servers).map(&:id).sort
  end

  test "user: updating invalid data" do
    login_user
    server = @user.servers.first
    name = server.firstname
    post settings_servers_path, params: { user: { servers: { server.id => { firstname: 'FEHLER!' }}}}
    assert_equal name, server.reload.firstname
  end

  test "server: requesting sizes" do
    login_server
    servers = Server.where(email: @server.email, user_id: nil)
    assert servers.count > 1, "Testcase is useless"

    get settings_servers_path
    assert assigns(:servers)
    assert_equal servers.map(&:id).sort, assigns(:servers).map(&:id).sort
  end

  test "server: updating valid size for servers" do
    login_server
    assert @server.siblings.count > 1, "Testcase is useless"
    servers = @server.siblings << @server
    server = @server.siblings.first

    post settings_servers_path, params: { user: { servers: { server.id => { size_talar: 150, size_rochet: 90 }}}}
    assert_response :success
    assert_template :servers
    assert_equal 150, server.reload.size_talar
    assert_equal 90, server.size_rochet
    assert_select '.alert.alert-success', I18n.t('settings.servers.changes_saved')
    assert assigns(:servers)
    assert_equal servers.map(&:id).sort, assigns(:servers).map(&:id).sort
  end

  test "server: updating valid size for invalid server" do
    login_server
    servers = Server.where(email: @server.email, user_id: nil)
    server = Server.all.without(servers).first

    post settings_servers_path, params: { user: { servers: { server.id => { size_talar: 150, size_rochet: 90 }}}}
    assert_response :success
    assert_template :servers
    assert_not_equal 150, server.reload.size_talar
    assert_not_equal 90, server.size_rochet
    assert_select '.alert.alert-success', I18n.t('settings.servers.changes_saved')
    assert assigns(:servers)
    assert_equal servers.map(&:id).sort, assigns(:servers).map(&:id).sort
  end

  test "deleting only accessible by users" do
    delete settings_delete_path
    assert_template 'sessions/new'

    login_server
    delete settings_delete_path
    assert_redirected_to settings_path

    login_user
    delete settings_delete_path
    assert_response :success
    assert_template 'user_mailer/user_deleted_mail'
    assert_template 'sessions/new'

    login_admin
    delete settings_delete_path
    assert_response :success
    assert_template partial: 'user_mailer/user_deleted_mail', count: 0
    assert_template 'sessions/new'
  end

  test "actually deleting account" do
    login_user

    servers = @user.servers
    seeds = servers.map(&:seed)
    email = @user.email
    id = @user.id

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      delete settings_delete_path
    end
    assert_template 'user_mailer/user_deleted_mail'
    assert_not User.find_by(id: id)
    servers.zip(seeds).each do |server, seed|
      assert_equal email, server.reload.email
      assert_nil server.user
      assert server.seed
      assert_not_equal seed, server.seed
    end

    assert_response :success
    assert_template 'sessions/new'
    assert_select '.alert.alert-info', I18n.t('sessions.new.user_deleted')
    assert_nil session[:user_id]
    assert_nil session[:server_id]
    assert_nil assigns(:current_user)
    assert_nil assigns(:current_server)
  end

  test "last root cant be deleted" do
    User.where(role: :root).without(@root).map(&:destroy)
    login_root

    delete settings_delete_path
    assert_response :success
    assert_template partial: 'user_mailer/user_deleted_mail', count: 0
    assert_template :delete
    assert_select '.alert.alert-danger', I18n.t('settings.delete.cant_delete_last_root')
  end

  test "highlight current controller action" do
    login_server
    get settings_path
    assert_select 'li.active a', I18n.t('settings.servers.title')

    get settings_servers_path
    assert_select 'li.active a', I18n.t('settings.servers.title')

    post settings_servers_path, params: { user: { servers: { @server.id => { firstname: 'test' }}}}
    assert_select 'li.active a', I18n.t('settings.servers.title')

    get settings_security_path
    assert_select 'li.active a', I18n.t('settings.security.title')

    get settings_security_generate_path
    assert_select 'li.active a', I18n.t('settings.security.title')

    login_user
    get settings_data_path
    assert_select 'li.active a', I18n.t('settings.data.title')

    post settings_data_path, params: { user: { email: 'test@bla.de' }}
    assert_select 'li.active a', I18n.t('settings.data.title')

    get settings_delete_path
    assert_select 'li.active a', I18n.t('settings.delete.title')
  end

  test "regenerate seed" do
    login_server

    servers_gen = @server.siblings << @server
    servers_nop = Server.all.without *servers_gen

    seeds_gen = servers_gen.map(&:seed)
    seeds_nop = servers_nop.map(&:seed)

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get settings_security_generate_path
    end
    assert_template 'server_mailer/seed_generated_mail'

    assert_response :success
    assert_select '.alert.alert-success', I18n.t('settings.security.success')
    assert_template :security

    seeds_nop.zip(servers_nop).each do |seed, server|
      assert_equal seed, server.reload.seed
    end
    seeds_gen.zip(servers_gen).each do |seed, server|
      assert_not_equal seed, server.reload.seed
    end
  end

end
