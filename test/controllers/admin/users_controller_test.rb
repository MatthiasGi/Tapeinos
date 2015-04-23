require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  def setup
    user = users(:root)
    session[:user_id] = user.id
    session[:server_id] = user.servers.first.id
  end

  test "index shows all users" do
    get :index
    assert_response :success
    assert_template :index
    assert_equal User.all, assigns(:users)
  end

  test "edit invalid user" do
    get :edit, { id: 1 }
    assert_redirected_to admin_users_path
  end

  test "edit valid user" do
    user = users(:max)
    get :edit, { id: user.id }
    assert_response :success
    assert_template :edit
    assert_equal user, assigns(:user)
  end

  test "update with wrong parameters" do
    user = users(:max)
    patch :update, { id: user.id, user: { email: 'testbla.de', password: 'test', password_confirmation: 'asdf' }}
    assert_response :success
    assert_template :edit
    assert_equal user, assigns(:user)
    assert_select '.user_email.has-error .help-block'
    assert_select '.user_password.has-error .help-block'
    assert_select '.user_password_confirmation.has-error .help-block'
  end

  test "update invalid parameters" do
    old = users(:max)
    patch :update, { id: old.id, user: { password_digest: 'testestetset', last_used: DateTime.now, password_reset_token: 'test', password_reset_expire: DateTime.now, failed_authentications: 3 }}
    assert_redirected_to admin_users_path
    new = User.find(old.id)
    assert_equal old.password_digest, new.password_digest
    assert_equal old.last_used, new.last_used
    assert_equal old.password_reset_token, new.password_reset_token
    assert_equal old.password_reset_expire, new.password_reset_expire
    assert_equal old.failed_authentications, new.failed_authentications
  end

  test "update valid parameters" do
    old = users(:max)
    patch :update, { id: old.id, user: { email: 'test@blabla.de', password: 'testtest', password_confirmation: 'testtest', role: :admin }}
    assert_redirected_to admin_users_path
    new = User.find(old.id)
    assert_equal 'test@blabla.de', new.email
    assert new.authenticate('testtest')
    assert new.admin? and new.administrator?
  end

  test "deleting user" do
    user = users(:max)
    delete :destroy, { id: user.id }
    assert_redirected_to admin_users_path
    assert_not User.find_by(id: user.id)
  end

  test "deleting invalid user" do
    delete :destroy, { id: 1 }
    assert_redirected_to admin_users_path
  end

  test "updating servers" do
    user = users(:max)
    old_servs = user.servers.map(&:id)
    new_servs = [ servers(:heinz), servers(:heinz2) ].map(&:id)
    patch :update, { id: user.id, user: { email: 'test@bla.de', server_ids: new_servs, role: :admin }}
    old_servs.each { |s| assert_not Server.find(s).user }
    new_servs.each { |s| assert_equal(user, Server.find(s).user) }
  end

  test "removing all servers" do
    user = users(:max)
    assert_not user.servers.empty?
    patch :update, { id: user.id, user: { server_ids: [] }}
    assert user.servers.empty?
    Server.all.each { |s| assert_not_equal(user, s.user) }
  end

end
