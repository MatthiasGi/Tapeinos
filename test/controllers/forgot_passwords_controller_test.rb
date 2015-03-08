require 'test_helper'

class ForgotPasswordsControllerTest < ActionController::TestCase

  test "displaying mask" do
    get :new
    assert_response :success
    assert_template :new
  end

  test "requesting for non-existant user" do
    post :create, { user: { email: 'testen@blablaablaaa.de' } }
    assert_template :new
    assert_select '.email.has-error .help-block', I18n.t('forgot_passwords.create.email_not_found')
  end

  test "requesting for valid user" do
    user = users(:max)
    user.clear_password_reset
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :create, { user: { email: user.email }}
    end
    user = User.find(user.id)
    assert_not user.password_reset_expired?
    assert_template :new
    assert_select '.alert.alert-success', I18n.t('forgot_passwords.new.mail_sent')
    assert_nil assigns(:user)

    # Requesting a second time should fail
    # only usec due to a rails-bug: http://stackoverflow.com/a/5568953
    time = user.password_reset_expire.usec
    post :create, { user: { email: user.email }}
    assert_equal time, User.find(user.id).password_reset_expire.usec
    assert_template :new
    assert_select '.alert.alert-warning', I18n.t('forgot_passwords.new.reset_link_already_sent')
    assert_equal user, assigns(:user)
  end

  test "requesting change with valid token" do
    user = users(:max)
    token = user.prepare_password_reset
    get :edit, { token: token }
    assert_response :success
    assert_template :edit
    assert_equal user, assigns(:user)
    assert_select '.page-header small', user.email
    assert_select 'input[type=hidden][name="user[password_reset_token]"][value=?]', token
  end

  test "requesting change with invalid token" do
    token = '123456789012345678901234567890af'
    get :edit, { token: token }
    assert_template :new
    assert_nil assigns(:user)
    assert_select '.alert.alert-danger', I18n.t('forgot_passwords.new.invalid_token')
  end

  test "requesting change with expired token" do
    user = users(:max)
    token = user.prepare_password_reset
    user.update({ password_reset_expire: 1.minute.ago })
    get :edit, { token: token }
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-warning', I18n.t('forgot_passwords.new.expired_token')
  end

  test "actually changing the password" do
    user = users(:max)
    token = user.prepare_password_reset
    user.update({ failed_authentications: 5 })
    assert user.blocked?
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :update, { user: { password: 'blabla', password_confirmation: 'blabla', password_reset_token: token }}
    end
    assert_template 'sessions/new'
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-success', I18n.t('sessions.new.password_changed')
    user = User.find(user.id)
    assert user.authenticate('blabla')
    assert_not user.blocked?
    assert_nil user.password_reset_token
    assert_nil user.password_reset_expire
  end

  test "providing unmatching password/confirmation" do
    user = users(:max)
    token = user.prepare_password_reset
    expire = user.password_reset_expire
    user.update({ failed_authentications: 5 })
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :update, { user: { password: 'blabla', password_confirmation: 'blabla2', password_reset_token: token }}
    end
    user = User.find(user.id)
    assert_template :edit
    assert_equal user, assigns(:user)
    assert_select '.user_password_confirmation.has-error .help-block'
    assert_not user.authenticate('blabla')
    assert user.blocked?
    assert_equal token, user.password_reset_token
    assert_equal expire, user.password_reset_expire
  end

  test "user is not allowed to change password (expired)" do
    user = users(:max)
    token = user.prepare_password_reset
    user.update({ failed_authentications: 5, password_reset_expire: 1.minute.ago })
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :update, { user: { password: 'blabla', password_confirmation: 'blabla2', password_reset_token: token }}
    end
    user = User.find(user.id)
    assert_template :new
    assert_equal user, assigns(:user)
    assert_select '.alert.alert-warning', I18n.t('forgot_passwords.new.expired_token')
    assert_not user.authenticate('blabla')
    assert user.blocked?
    assert user.password_reset_token
    assert user.password_reset_expire
  end

  test "changing with invalid token" do
    user = users(:max)
    user.prepare_password_reset
    user.update({ failed_authentications: 5, password_reset_token: '12345678901234567890123456789012' })
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :update, { user: { password: 'blabla', password_confirmation: 'blabla2', password_reset_token: '123456789012345678901234567890af' }}
    end
    user = User.find(user.id)
    assert_template :new
    assert_nil assigns(:user)
    assert_select '.alert.alert-danger', I18n.t('forgot_passwords.new.invalid_token')
    assert_not user.authenticate('blabla')
    assert user.blocked?
    assert user.password_reset_token
    assert user.password_reset_expire
  end

end
