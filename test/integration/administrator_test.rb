require 'test_helper'

class AdministratorTest < ActionDispatch::IntegrationTest

  test "No menu-item for non-administrators" do
    user = users(:max)
    post_via_redirect login_path, { user: { email: user.email, password: 'testen' }}
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', false
  end

  test "Menu-item for administrators" do
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}
    assert_template 'plans/index'
    assert_select '.navbar-nav [href="' + admin_servers_path + '"]', I18n.t('defaults.administration')
  end

  test "Administrative layout on administration" do
    user = users(:admin)
    post_via_redirect login_path, { user: { email: user.email, password: 'testtest' }}
    get_via_redirect admin_servers_path
    assert_template 'layouts/administration'
  end

end
