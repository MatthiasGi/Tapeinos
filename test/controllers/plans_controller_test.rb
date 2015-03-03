require 'test_helper'

class PlansControllerTest < ActionController::TestCase

  test "only logged in user allowed" do
    get :index, nil, nil
    assert_response :success
    assert_template 'sessions/new'

    user = users(:max)
    get :index, nil, {user_id: user.id}
    assert_response :success
    assert_template :index
  end

end
