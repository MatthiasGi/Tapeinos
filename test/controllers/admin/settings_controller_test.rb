require 'test_helper'

class Admin::SettingsControllerTest < ActionController::TestCase

  def setup
    user = users(:root)
    session[:user_id] = user.id
    session[:server_id] = user.servers.first.id
  end

  def settings_tester
    config = SettingsHelper.getHash
    assert settings = assigns(:settings)
    assert_equal config[:domain], settings.domain
    assert_equal config[:redis], settings.redis
    assert_equal config[:email_server], settings.email_server
    assert_equal config[:email_port], settings.email_port
    assert_equal config[:email_username], settings.email_username
    assert_equal " " * config[:email_password].size, settings.email_password
    assert_equal config[:email_email], settings.email_email
    assert_equal config[:email_name], settings.email_name
    assert_equal config[:timezone], settings.timezone
    assert_nil settings.redis_down
    assert_nil settings.sidekiq_down
    assert_nil settings.sidekiq_mailer_down
    assert_nil settings.required_restart
  end

  test "index sets all available settings" do
    get :index
    assert_response :success
    assert_template :index
    settings_tester
  end

  test "Empty password" do
    password = SettingsHelper.get(:email_password)

    SettingsHelper.set(:email_password, '')
    get :index
    assert_equal '', assigns(:settings).email_password

    SettingsHelper.set(:email_password, password)
  end

  test "update lists settings" do
    post :update, settings: {}
    assert_response :success
    assert_template :index
    assert_not SettingsHelper.get(:restart_required)
    settings_tester
  end

  test "updates saves settings" do
    old_settings = SettingsHelper.getHash
    new_settings = {
        domain: 'blabla',
        redis: 'testen',
        email_server: 'smtptest',
        email_port: '987',
        email_username: 'usertset',
        email_password: 'passworddd',
        email_email: 'test@blabla.test.de',
        email_name: 'Namer',
        timezone: 'Edinburgh'
      }

    post :update, settings: new_settings
    new_settings.each do |key, value|
      assert_equal value, SettingsHelper.get(key)
    end
    assert SettingsHelper.get(:restart_required)

    SettingsHelper.setHash(old_settings)
    SettingsHelper.set(:restart_required, false)
  end

  test "don't set password to blank with old length" do
    old_pw = SettingsHelper.get(:email_password)
    get :index
    settings = assigns(:settings)
    post :update, settings: { email_password: settings[:email_password] }
    assert_equal old_pw, SettingsHelper.get(:email_password)
    assert_not SettingsHelper.get(:restart_required)
  end

  test "don't set other settings" do
    redis = !SettingsHelper.get(:redis_up)
    post :update, settings: { redis_up: redis }
    assert_not_equal redis, SettingsHelper.get(:redis_up)
  end

end
