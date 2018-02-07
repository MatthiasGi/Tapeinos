require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  def setup
    user = users(:admin)
    post login_path, params: { user: { email: user.email, password: 'testtest' }}
    follow_redirect!
  end

  def _menu_bar_admin_test
    get root_path
    assert_template 'plans/index'
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', Plan.model_name.human(count: :many)

    get plan_path(Plan.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', Plan.model_name.human(count: :many)

    get admin_servers_path
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')

    get edit_admin_server_path(Server.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')

    get admin_plan_path(Plan.all.first)
    assert_select '.navbar-nav .active', 1
    assert_select '.navbar-nav li.active a', I18n.t('defaults.administration')
  end

  test "menubar should show current controller (admin)" do
    _menu_bar_admin_test
  end

  test "menubar should show current controller (root)" do
    post login_path, params: { user: { email: users(:root).email, password: 'testen' }}
    follow_redirect!
    _menu_bar_admin_test
  end

  test "administrator has only visible servers, plans and messages" do
    get admin_plans_path
    assert_select '.nav-pills.nav-stacked li', 3
  end

  test "root has visible servers, plans, users, settings and messages" do
    post login_path, params: { user: { email: users(:root).email, password: 'testen' }}
    follow_redirect!
    get admin_plans_path
    assert_select '.nav-pills.nav-stacked li', 5
  end

end
