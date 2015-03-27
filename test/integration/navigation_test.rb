require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  def setup
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}
  end

  test "menubar should show current controller" do
    get_via_redirect root_path
    assert_template 'plans/index'
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', Plan.model_name.human(count: :many)

    get_via_redirect plan_path(Plan.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', Plan.model_name.human(count: :many)

    get_via_redirect admin_servers_path
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')

    get_via_redirect edit_admin_server_path(Server.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')

    get_via_redirect admin_plan_path(Plan.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')
  end

end
