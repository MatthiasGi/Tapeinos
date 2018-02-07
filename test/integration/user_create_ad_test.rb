require 'test_helper'

class UserCreateAdTest < ActionDispatch::IntegrationTest

  test "get register advertising" do
    server = servers(:heinz)
    get login_seed_path(server.seed)
    follow_redirect!

    assert_template 'plans/index'
    assert_select '.panel .btn', I18n.t('defaults.register.submit')
    get change_server_path(server.siblings.first.id), headers: { HTTP_REFERER: plans_path }
    follow_redirect!

    assert_template 'plans/index'
    assert_select '.panel .btn', I18n.t('defaults.register.submit')
  end

  test "no advertise on logged in user" do
    user = users(:max)
    post login_path, params: { user: { email: user.email, password: 'testen' }}
    follow_redirect!

    assert_template 'plans/index'
    assert_select '.panel .btn', false

    # The following was added due to bug #9
    assert assigns(:current_server)
    other = assigns(:current_server).siblings.first
    get change_server_path(other.id), headers: { HTTP_REFERER: plans_path }
    follow_redirect!
    assert_template 'plans/index'
    assert_equal user, assigns(:current_user)
    assert_equal other, assigns(:current_server)
    assert_select '.panel .btn', false
  end

end
