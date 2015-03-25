require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  
  test "about page visible for logged in servers" do
    get :about, nil, { server_id: Server.first.id }
    assert_response :success
    assert_template :about
  end
  
  test "about page not visible to external" do
    get :about
    assert_response :success
    assert_template 'sessions/new'
  end
  
  test "about shows localized changelog" do
    I18n.locale = 'de'
    get :about, nil, { server_id: Server.first.id }
    assert_equal 'CHANGELOG.de.md', assigns(:changelog)
  end
  
  test "about defaults to english changelog" do
    I18n.locale = 'en'
    get :about, nil, { server_id: Server.first.id }
    assert_equal 'CHANGELOG.md', assigns(:changelog)
    I18n.locale = 'de'
  end
  
end
