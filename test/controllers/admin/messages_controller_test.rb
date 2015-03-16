require 'test_helper'

class Admin::MessagesControllerTest < ActionController::TestCase

  def setup
    user = users(:admin)
    session[:user_id] = user.id
    session[:server_id] = user.servers.first.id
  end

  test "index shows all messages" do
    get :index
    assert_response :success
    assert_template :index
    assert_equal Message.all.order(date: :desc), assigns(:messages)
  end

end
