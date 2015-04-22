require 'test_helper'

class SetupControllerTest < ActionController::TestCase
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!

  def setup
    User.destroy_all
    File.exists?('SETUP_CODE') and File.delete('SETUP_CODE')
    @authenticated = { authenticated: true }
  end

  def settings_tester
    config = SettingsHelper.getHash
    assert settings = assigns(:settings)
    config[:domain] and assert_equal config[:domain], settings.domain
    config[:redis] and assert_equal config[:redis], settings.redis
    config[:email_server] and assert_equal config[:email_server], settings.email_server
    config[:email_port] and assert_equal config[:email_port], settings.email_port
    assert_equal config[:email_username], settings.email_username
    assert_equal " " * config[:email_password].size, settings.email_password
    assert_equal config[:email_email], settings.email_email
    assert_equal config[:email_name], settings.email_name
    config[:timezone] and assert_equal config[:timezone], settings.timezone
    assert_nil settings.redis_down
    assert_nil settings.sidekiq_down
    assert_nil settings.sidekiq_mailer_down
    assert_nil settings.restart_required
  end

  test "provide default options for first run" do
    old_settings = SettingsHelper.getHash
    defaults = {
      domain: 'http://test.host',
      redis: 'redis://localhost:6379',
      timezone: 'UTC',
      email_server: 'smtp.gmail.com',
      email_port: 587
    }
    defaults.each { |k, v| SettingsHelper.set(k, nil) }
    get :show, { id: :domain }, @authenticated

    defaults.each do |key, value|
      assert_equal value, assigns(:settings)[key]
    end

    SettingsHelper.setHash(old_settings)
  end

  test "setup destroys session information" do
    server = servers(:heinz)
    get :show, { id: :authenticate }, { server_id: server.id }
    assert_response :success
    assert_template :authenticate
    assert_nil session[:server_id]
    assert_not assigns(:current_server)
  end

  test "setup not available if a user is available" do
    user = User.new(email: 'test@bla.de', password: 'testen')
    assert user.save
    get :show, id: :authenticate
    assert_redirected_to root_path
  end

  test "setup generates authentication key" do
    get :show, id: :authenticate
    assert_response :success
    assert_template :authenticate
    assert File.exists?('SETUP_CODE')
    assert_not assigns(:settings)
  end

  test "existing file gets overwritten" do
    File.write('SETUP_CODE', 'blabla')
    get :show, id: :authenticate
    assert_response :success
    assert_template :authenticate
    assert_not_equal 'blabla', File.read('SETUP_CODE')
    assert File.read('SETUP_CODE').size == 44, "#{File.read('SETUP_CODE').size}"
  end

  test "authenticating with correct token works" do
    get :show, id: :authenticate
    token = File.read('SETUP_CODE')
    put :update, { id: :authenticate, token: token }
    assert_redirected_to '/setup/domain'
    assert_not File.exists?('SETUP_CODE')
  end

  test "authenticating with incorrect token yields error" do
    get :show, id: :authenticate
    put :update, { id: :authenticate, token: 'asdf' }
    assert_response :success
    assert_template :authenticate
    assert_select '.alert.alert-danger', I18n.t('setup.authenticate.invalid_token')
    assert_not assigns(:settings)
  end

  test "authenticating without file yields error" do
    put :update, { id: :authenticate, token: 'asdf' }
    assert_response :success
    assert_template :authenticate
    assert_select '.alert.alert-danger', I18n.t('setup.authenticate.invalid_token')
    assert_not assigns(:settings)
  end

  test "calling wrong action without first authenticating fails" do
    get :show, id: :domain
    assert_redirected_to '/setup/authenticate'
    assert_not assigns(:settings)
  end

  test "calling when authenticated works" do
    get :show, { id: :domain }, @authenticated
    assert_response :success
    assert_template :domain
    settings_tester
  end

  test "Saving redis-server, domain and time-zone creates file with data" do
    domain = SettingsHelper.get(:domain)
    redis = SettingsHelper.get(:redis)
    timezone = SettingsHelper.get(:timezone)

    SettingsHelper.set(:restart_required, false)
    put :update, { id: :domain, settings: { domain: 'test', redis: 'bla', timezone: 'Berlin' }}
    assert_redirected_to '/setup/mailer'
    assert_equal 'test', SettingsHelper.get(:domain)
    assert_equal 'bla', SettingsHelper.get(:redis)
    assert_equal 'Berlin', SettingsHelper.get(:timezone)
    assert SettingsHelper.get(:restart_required, false)
    SettingsHelper.set(:restart_required, false)

    get :show, { id: :domain }, @authenticated
    settings_tester
    assert_equal 'test', assigns(:settings)[:domain]
    assert_equal 'bla', assigns(:settings)[:redis]
    assert_equal 'Berlin', assigns(:settings)[:timezone]

    SettingsHelper.set(:domain, domain)
    SettingsHelper.set(:redis, redis)
    SettingsHelper.set(:timezone, timezone)
  end

  test "Display already saved things" do
    domain = SettingsHelper.get(:domain)
    redis = SettingsHelper.get(:redis)
    timezone = SettingsHelper.get(:timezone)

    get :show, { id: :domain }, @authenticated
    settings_tester
    assert_equal domain, assigns(:settings)[:domain]
    assert_equal redis, assigns(:settings)[:redis]
    assert_equal timezone, assigns(:settings)[:timezone]
  end

  test "mailer only if authenticated" do
    get :show, { id: :mailer }
    assert_redirected_to setup_path(:authenticate)
    assert_not assigns(:settings)
    assert_not SettingsHelper.get(:restart_required)

    get :show, { id: :mailer }, @authenticated
    settings_tester
    assert_response :success
    assert_template :mailer
  end

  test "mailer settings saved" do
    settings = {
      email_server: SettingsHelper.get(:email_server),
      email_port: SettingsHelper.get(:email_port),
      email_username: SettingsHelper.get(:email_username),
      email_password: SettingsHelper.get(:email_password),
      email_email: SettingsHelper.get(:email_email),
      email_name: SettingsHelper.get(:email_name),
    }

    SettingsHelper.set(:restart_required, false)
    put :update, { id: :mailer, settings: { email_server: 'test', email_port: 3, email_username: 'bla', email_password: 'testen', email_email: 'blubb', email_name: 'heinz' }}, @authenticated
    assert SettingsHelper.get(:restart_required, false)
    SettingsHelper.set(:restart_required, false)

    assert_redirected_to setup_path(:server)
    assert_equal 'test', SettingsHelper.get(:email_server)
    assert_equal '3', SettingsHelper.get(:email_port)
    assert_equal 'bla', SettingsHelper.get(:email_username)
    assert_equal 'testen', SettingsHelper.get(:email_password)
    assert_equal 'blubb', SettingsHelper.get(:email_email)
    assert_equal 'heinz', SettingsHelper.get(:email_name)

    settings.each do |key, value|
      SettingsHelper.set(key, value)
    end
  end

  test "mailer shows already saved settings" do
    attr = [:server, :port, :username, :password, :email, :name]
    attr.collect { |s| "email_#{s}".to_sym }
    get :show, { id: :mailer }, @authenticated
    settings_tester
    attr.each do |key|
      assert_equal SettingsHelper.get(key), assigns(:settings)[key]
    end
  end

  test "creating server with invalid data" do
    put :update, { id: :server, server: { email: 'testbla.de' }}
    assert_not assigns(:settings)
    assert_response :success
    assert_template :server
    assert_select '.server_firstname.has-error .help-block'
    assert_select '.server_lastname.has-error .help-block'
    assert_select '.server_email.has-error .help-block'
    assert_select '.server_sex.has-error .help-block'
  end

  test "creating server with valid data" do
    Server.destroy_all
    put :update, { id: :server, server: { firstname: 'Test', lastname: 'Bla', email: 'test@bla.de', sex: :female }}
    assert_not assigns(:settings)
    assert_response :success
    assert_template :finish
    server = Server.all.first
    assert_equal 'Test', server.firstname
    assert_equal 'Bla', server.lastname
    assert_equal 'test@bla.de', server.email
    assert server.female?
    assert_not server.male?

    assert server.user
    user = User.all.first
    assert user.root?
    assert_equal server.user, user
    assert_equal 'test@bla.de', user.email

    assert user.authenticate(assigns(:password))
  end

  test "Only settings-pages which need settings should get them" do
    get :show, id: :authenticate
    assert_not assigns(:settings)
    get :show, { id: :server }, @authenticated
    assert_not assigns(:settings)
    get :show, { id: :finish }, @authenticated
    assert_not assigns(:settings)
    get :show, { id: :domain }, @authenticated
    settings_tester
  end

  test "Settings in mailer-settings" do
    get :show, { id: :mailer }, @authenticated
    settings_tester
  end

end
