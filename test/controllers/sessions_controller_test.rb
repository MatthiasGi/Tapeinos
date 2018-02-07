require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    request.env["HTTP_REFERER"] = plans_path
  end

  test "new session stub" do
    get :new
    assert_response :success
    assert_template :new
  end

  test "creating new sessions" do
    user = users(:max)

    # Wrong email
    email = 'test@bla.de'
    post :create, params: { user: { email: email }}
    assert_response :success
    assert_template :new
    assert_select '.email.has-error .help-block', I18n.t('sessions.create.email_not_found')
    assert_equal email, assigns(:user).email
    assert_nil assigns(:current_user)

    # Wrong password
    post :create, params: { user: { email: user.email, password: 'wrongpass' }}
    assert_response :success
    assert_template :new
    assert_select '.email.has-error', false
    assert_select '.password.has-error .help-block', I18n.t('sessions.create.password_wrong')
    assert_equal user.email, assigns(:user).email
    user = User.find(user.id)
    assert_equal 1, user.failed_authentications
    assert_nil assigns(:current_user)

    # Everything right
    used = user.last_used
    post :create, params: { user: { email: user.email, password: 'testen' }}
    assert_equal user.id, session[:user_id]
    user = User.find(session[:user_id])
    assert_not_equal used, user.last_used
    assert_equal 0, user.failed_authentications
    assert_redirected_to root_path
  end

  test "reset password reset on login" do
    user = users(:max)
    user.prepare_password_reset
    post :create, params: { user: { email: user.email, password: 'testen' }}
    user = User.find(user.id)
    assert_nil user.password_reset_token
    assert_nil user.password_reset_expire
  end

  test "logout" do
    user = users(:max)
    delete :destroy, session: { user_id: user.id, server_id: user.servers.first.id }
    assert_nil session[:user_id]
    assert_response :success
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-success', I18n.t('sessions.new.logout')
    assert_nil assigns(:current_user)
  end

  test "no logout message if not appropriate" do
    delete :destroy
    assert_template :new
    assert_select '.alert.alert-success', false
  end

  test "blocked accounts should not be able to log in" do
    user = users(:max)
    user.update(failed_authentications: 5)
    post :create, params: { user: { email: user.email, password: 'testen' }}
    assert_nil session[:user_id]
    assert_response :success
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-danger', I18n.t('sessions.new.blocked')

    # Blocked should not provide hints about real password.
    post :create, params: { user: { email: user.email, password: 'wrong_pass' }}
    assert_select '.alert.alert-danger', I18n.t('sessions.new.blocked')
    assert_select '.password.has-error', false
  end

  test "No current user on login" do
    user = users(:max)
    get :new, session: { user_id: user.id }
    assert_response :success
    assert_template :new
    assert_nil assigns(:user)
    assert_nil assigns(:current_user)
  end

  test "login by seed" do
    server = servers(:heinz)
    used = server.last_used
    get :temporary, params: { seed: server.seed }
    assert_not_equal used, Server.find(server.id).last_used
    assert_equal server.id, session[:server_id]
    assert_redirected_to root_path
  end

  test "login of server with user should fail" do
    server = servers(:max)
    get :temporary, params: { seed: server.seed }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_equal server.user, assigns(:user)
    assert_select '.alert.alert-warning', I18n.t('sessions.new.server_has_account')
  end

  test "login with invalid seed" do
    get :temporary, params: { seed: '12345678901234567890123456789012' }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_seed')
  end

  test "logout server by different means" do
    server = servers(:heinz)
    get :temporary, params: { seed: server.seed }
    get :destroy
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_select '.alert.alert-success', I18n.t('sessions.new.logout')

    get :temporary, params: { seed: server.seed }
    get :temporary, params: { seed: '12345678901234567890123456789012' }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)

    get :temporary, params: { seed: server.seed }
    get :new
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)

    get :temporary, params: { seed: server.seed }
    post :create, params: { user: { email: nil }}
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
  end

  test "logging in user logs in first available server" do
    user = users(:max)
    used = user.servers.first
    post :create, params: { user: { email: user.email, password: 'testen' }}
    server = user.servers.reload.first
    assert_equal server.id, session[:server_id]
    assert_not_equal used, server.last_used
  end

  test "logging in user without server fails" do
    user = users(:monika)
    post :create, params: { user: { email: user.email, password: 'blabla' }}
    assert_template :new
    assert_select '.alert.alert-danger', I18n.t('sessions.new.no_server_available')
    assert_nil session[:user_id]
    assert_nil assigns(:current_user)
  end

  test "changing user-managed servers" do
    user = users(:max)
    used = user.servers.second.last_used
    get :update, params: { id: user.servers.second }, session: { user_id: user.id, server_id: user.servers.first.id }
    assert_redirected_to plans_path
    assert_equal user.servers.second.id, session[:server_id]
    assert_not_equal used, user.servers.reload.second.last_used
  end

  test "changing server-managed servers" do
    server = servers(:heinz)
    used = server.last_used
    get :update, params: { id: server.id }, session: { server_id: servers(:heinz2).id }
    assert_redirected_to plans_path
    server = Server.find(server.id)
    assert_not_equal used, server.last_used
    assert_equal server.id, session[:server_id]
  end

  test "changing servers with invalid servers" do
    user = users(:max)

    # Invalid server
    get :update, params: { id: 20 }, session: { user_id: user.id, server_id: user.servers.first.id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_equal user, assigns(:user)

    # User may not manage server
    server = servers(:heinz)
    get :update, params: { id: server.id }, session: { user_id: user.id, server_id: user.servers.first.id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_equal user, assigns(:user)

    # Servers do not have equal email-addresses
    get :update, params: { id: servers(:heinz).id }, session: { server_id: servers(:kunz).id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_nil assigns(:user)

    # New server managed by user
    get :update, params: { id: servers(:heinz).id }, session: { server_id: servers(:max4).id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_nil assigns(:user)
  end

  test "changing server to itself" do
    server = servers(:heinz)
    get :update, params: { id: server.id }, session: { server_id: server.id }
    assert_redirected_to plans_path
    assert_equal server.id, session[:server_id]
  end

  test "Calling user login by email" do
    user = users(:max)
    get :new, params: { email: user.email }
    assert_response :success
    assert_template :new
    assert_equal user, assigns(:user)
  end

  test "Calling login with email of server" do
    server = servers(:heinz)
    get :new, params: { email: server.email }
    assert_response :success
    assert_template :new
    assert_not assigns(:user)
    assert_select '.alert.alert-warning', I18n.t('sessions.new.server_has_no_account')
  end

  test "Calling login with invalid email" do
    get :new, params: { email: 'testen@invalid.notexisting.de' }
    assert_response :success
    assert_template :new
    assert_not assigns(:user)
  end

end
