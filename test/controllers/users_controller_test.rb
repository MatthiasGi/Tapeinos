require 'test_helper'

class UsersControllerTest < ActionController::TestCase

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

end
