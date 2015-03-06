require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    request.env["HTTP_REFERER"] = root_path
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
    post :create, {user: {email: email}}
    assert_response :success
    assert_template :new
    assert_select '.email.has-error .help-block', I18n.t('sessions.create.email_not_found')
    assert_equal email, assigns(:user).email
    assert_nil assigns(:current_user)

    # Wrong password
    post :create, {user: {email: user.email, password: 'wrongpass'}}
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
    post :create, {user: {email: user.email, password: 'testen'}}
    assert_equal user.id, session[:user_id]
    user = User.find(session[:user_id])
    assert_not_equal used, user.last_used
    assert_equal 0, user.failed_authentications
    assert_redirected_to root_path
  end

  test "reset password reset on login" do
    user = users(:max)
    user.prepare_password_reset
    post :create, {user: {email: user.email, password: 'testen'}}
    user = User.find(user.id)
    assert_nil user.password_reset_token
    assert_nil user.password_reset_expire
  end

  test "logout" do
    user = users(:max)
    delete :destroy, nil, {user_id: user.id, server_id: user.servers.first.id}
    assert_nil session[:user_id]
    assert_response :success
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-success', I18n.t('sessions.new.logout')
    assert_nil assigns(:current_user)
  end

  test "no logout message if not appropriate" do
    delete :destroy, nil, nil
    assert_template :new
    assert_select '.alert.alert-success', false
  end

  test "blocked accounts should not be able to log in" do
    user = users(:max)
    user.update(failed_authentications: 5)
    post :create, {user: {email: user.email, password: 'testen'}}
    assert_nil session[:user_id]
    assert_response :success
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-danger', I18n.t('sessions.new.blocked')

    # Blocked should not provide hints about real password.
    post :create, {user: {email: user.email, password: 'wrong_pass'}}
    assert_select '.alert.alert-danger', I18n.t('sessions.new.blocked')
    assert_select '.password.has-error', false
  end

  test "No current user on login" do
    user = users(:max)
    get :new, nil, {user_id: user.id}
    assert_response :success
    assert_template :new
    assert_nil assigns(:user)
    assert_nil assigns(:current_user)
  end

  test "login by seed" do
    server = servers(:heinz)
    get :temporary, { seed: server.seed }
    assert_equal server.id, session[:server_id]
    assert_redirected_to root_path
  end

  test "login of server with user should fail" do
    server = servers(:max)
    get :temporary, { seed: server.seed }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_equal server.user, assigns(:user)
    assert_select '.alert.alert-warning', I18n.t('sessions.new.server_has_account')
  end

  test "login with invalid seed" do
    get :temporary, { seed: '12345678901234567890123456789012' }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_seed')
  end

  test "logout server by different means" do
    server = servers(:heinz)
    get :temporary, { seed: server.seed }
    get :destroy
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
    assert_template :new
    assert_select '.alert.alert-success', I18n.t('sessions.new.logout')

    get :temporary, { seed: server.seed }
    get :temporary, { seed: '12345678901234567890123456789012' }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)

    get :temporary, { seed: server.seed }
    get :new
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)

    get :temporary, { seed: server.seed }
    post :create, { user: { email: nil } }
    assert_nil session[:server_id]
    assert_nil assigns(:current_server)
  end

  test "logging in user logs in first available server" do
    user = users(:max)
    post :create, {user: {email: user.email, password: 'testen'}}
    server = user.servers.first
    assert_equal server.id, session[:server_id]
  end

  test "logging in user without server fails" do
    user = users(:monika)
    post :create, {user: {email: user.email, password: 'blabla'}}
    assert_template :new
    assert_select '.alert.alert-danger', I18n.t('sessions.new.no_server_available')
    assert_nil session[:user_id]
    assert_nil assigns(:current_user)
  end

  test "changing user-managed servers" do
    user = users(:max)
    get :update, { id: user.servers.second }, { user_id: user.id, server_id: user.servers.first.id }
    assert_redirected_to root_path
    assert_equal user.servers.second.id, session[:server_id]
  end

  test "changing server-managed servers" do
    server = servers(:heinz)
    get :update, { id: server.id }, { server_id: servers(:heinz2).id }
    assert_redirected_to root_path
    assert_equal session[:server_id], server.id
  end

  test "changing servers with invalid servers" do
    user = users(:max)

    # Invalid server
    get :update, { id: 20 }, { user_id: user.id, server_id: user.servers.first.id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_equal user, assigns(:user)

    # User may not manage server
    server = servers(:heinz)
    get :update, { id: server.id }, { user_id: user.id, server_id: user.servers.first.id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_equal user, assigns(:user)

    # Servers do not have equal email-addresses
    get :update, { id: servers(:heinz).id }, { server_id: servers(:kunz).id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_nil assigns(:user)

    # New server managed by user
    get :update, { id: servers(:heinz).id }, { server_id: servers(:max4).id }
    assert_template :new
    assert_nil session[:server_id]
    assert_nil session[:user_id]
    assert_select '.alert.alert-danger', I18n.t('sessions.new.invalid_server_change')
    assert_nil assigns(:user)
  end

end
