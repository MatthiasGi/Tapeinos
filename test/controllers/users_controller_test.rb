require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    user = users(:max)
    @session = { server_id: user.servers.first.id, user_id: user.id }
  end

  test "get new display only for servers" do
    get :new, nil, nil
    assert_response :success
    assert_template 'sessions/new'

    server = servers(:heinz)
    get :new, nil, { server_id: server.id }
    assert_response :success
    assert_template :new

    server = servers(:max)
    get :new, nil, { server_id: server.id, user_id: server.user.id }
    assert_redirected_to plans_path
  end

  test "create account not for users or invalid servers" do
    get :create, nil, nil
    assert_response :success
    assert_template 'sessions/new'

    server = servers(:max)
    get :create, nil, { server_id: server.id, user_id: server.user.id }
    assert_redirected_to plans_path
  end

  test "create account" do
    server = servers(:heinz)
    email = server.email
    siblings = server.siblings
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get :create, nil, { server_id: server.id }
    end
    server = Server.find(server.id)
    assert_response :success
    assert_template 'sessions/new'

    assert_nil session[:user_id]
    assert_nil session[:server_id]
    assert_nil assigns(:current_user)
    assert_nil assigns(:current_server)

    user = User.find_by(email: email)
    assert_equal user, server.user
    assert_equal email, user.email
    assert_equal email, server.email
    assert_equal siblings, server.siblings

    server.siblings.each do |server|
      assert_equal user, server.user
    end

    assert_equal user, assigns(:user)

    assert_select '.alert.alert-success', I18n.t('sessions.new.user_created')
  end

  test "settings only available to registered users" do
    get :edit, nil, nil
    assert_template 'sessions/new'

    server = servers(:heinz)
    get :edit, nil, { server_id: server.id }
    assert_redirected_to root_path

    user = users(:max)
    get :edit, nil, { server_id: user.servers.first.id, user_id: user.id }
    assert_template :edit
    assert_response :success
  end

  test "update only available to registered users" do
    post :update, nil, nil
    assert_template 'sessions/new'

    server = servers(:heinz)
    post :update, nil, { server_id: server.id }
    assert_redirected_to root_path

    post :update, { user: { test: nil }}, @session
    assert_template :edit
    assert_response :success
  end

  test "updating user-values with invalid email" do
    post :update, { user: { email: 'testen.de' }}, @session
    user = User.find(users(:max).id)
    assert_template :edit
    assert_select '.alert.alert-success', false
    assert_not_equal 'testen.de', user.email
    assert_select '.user_email.has-error .help-block'
  end

  test "updating user-values only with email" do
    post :update, { user: { email: 'test@bla.de' }}, @session
    user = User.find(users(:max).id)
    assert_template :edit
    assert_select '.alert.alert-success', I18n.t('users.edit.changes_saved')
    assert_equal 'test@bla.de', user.email
  end

  test "updating user-values only with password" do
    post :update, { user: { password: 'testenen', password_confirmation: 'testenen' }}, @session
    user = User.find(users(:max).id)
    assert user.authenticate('testenen')
    assert_template :edit
    assert_select '.alert.alert-success'
  end

  test "updating user-values with wrong confirmation" do
    post :update, { user: { password: 'testenen', password_confirmation: 'testenem' }}, @session
    user = User.find(users(:max).id)
    assert_template :edit
    assert_select '.alert.alert-success', false
    assert_select '.user_password_confirmation.has-error .help-block'
    assert_not user.authenticate('testenen') or user.authenticate('testenem')
  end

  test "updating user-values with invalid password" do
    post :update, { user: { password: 'test', password_confirmation: 'test' }}, @session
    user = User.find(users(:max).id)
    assert_template :edit
    assert_select '.alert.alert-success', false
    assert_select '.user_password.has-error .help-block'
    assert_not user.authenticate('test')
  end

  test "updating valid size for servers" do
    server = users(:max).servers.first
    post :update, { user: { servers_attributes: { id: server.id, size_talar: 150, size_rochet: 90 }}}, @session
    server = Server.find(server.id)
    assert_template :edit
    assert_select '.alert.alert-success', I18n.t('users.edit.changes_saved')
    assert_equal 150, server.size_talar
    assert_equal 90, server.size_rochet
  end

  test "updating invalid sizes for servers" do
    server = users(:max).servers.first
    post :update, { user: { servers_attributes: { id: server.id, size_talar: 180, size_rochet: 200 }}}, @session
    server = Server.find(server.id)
    assert_template :edit
    assert_select '.alert.alert-success', false
    assert_not_equal 180, server.size_talar
    assert_not_equal 200, server.size_rochet
    assert_select 'table .help-block', 2
  end

  test "deleting account" do
    user = users(:max)
    servers = user.servers
    testseed = servers.first.seed
    email = user.email
    id = user.id
    server = servers.first
    servers.update_all(email: 'test@blabla.de')

    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      delete :destroy, nil, @session
    end
    assert_not User.find_by(id: id)
    servers.each do |server|
      assert_equal email, server.email
      assert_not server.user
      assert server.seed
    end
    server = Server.find(server.id)
    assert_not_equal testseed, server.seed
    assert_template 'sessions/new'
    assert_select '.alert.alert-info', I18n.t('sessions.new.user_deleted')
    assert_nil session[:user_id]
    assert_nil session[:server_id]
    assert_nil assigns(:current_user)
    assert_nil assigns(:current_server)
  end

end
