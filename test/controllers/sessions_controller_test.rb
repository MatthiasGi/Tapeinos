require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

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
    delete :destroy, nil, {user_id: user.id}
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

end
