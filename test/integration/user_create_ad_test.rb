require 'test_helper'

class UserCreateAdTest < ActionDispatch::IntegrationTest

  test "get register advertising" do
    server = servers(:heinz)
    get_via_redirect login_seed_path(server.seed)

    assert_template 'plans/index'
    assert_select '.panel .btn', I18n.t('defaults.register.submit')
    get_via_redirect change_server_path(server.siblings.first.id), nil, referer: plans_path

    assert_template 'plans/index'
    assert_select '.panel .btn', I18n.t('defaults.register.submit')
  end

  test "no advertise on logged in user" do
    user = users(:max)
    post_via_redirect login_path, { user: { email: user.email, password: 'testen' }}

    assert_template 'plans/index'
    assert_select '.panel .btn', false

    # The following was added due to bug #9
    assert assigns(:current_server)
    other = assigns(:current_server).siblings.first
    get_via_redirect change_server_path(other.id), nil, referer: plans_path
    assert_template 'plans/index'
    assert_equal user, assigns(:current_user)
    assert_equal other, assigns(:current_server)
    assert_select '.panel .btn', false
  end

end
