require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "new session stub" do
    get :new
    assert_response :success
  end

end
