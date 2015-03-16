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

  test "show invalid message" do
    get :show, { id: 1 }
    assert_redirected_to admin_messages_path
  end

  test "show valid message" do
    message = messages(:one)
    get :show, { id: message.id }
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
  end

  test "draft message show with send" do
    message = messages(:one)
    get :show, { id: message.id }
    assert_template :show
    assert_select '.btn.btn-primary'
    assert_select '.btn.btn-default .glyphicon-pencil'
    assert_select '.btn.btn-danger'
  end

  test "sent message shows without send" do
    message = messages(:two)
    get :show, { id: message.id }
    assert_template :show
    assert_select '.btn.btn-primary', false
    assert_select '.btn.btn-default .glyphicon-pencil', false
    assert_select '.btn.btn-danger'
  end

end
