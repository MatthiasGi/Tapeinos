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
    assert ActionMailer::Base.deliveries.empty?
    post :create, { user: { email: user.email }}
    user = User.find(user.id)
    assert_not user.password_reset_expired?
    assert_not ActionMailer::Base.deliveries.empty?
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

end
