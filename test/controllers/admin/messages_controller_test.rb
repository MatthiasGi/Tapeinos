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
    assert_equal Message.all, assigns(:messages)
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
    assert_select '.btn.btn-danger', false
  end

  test "edit invalid message" do
    get :edit, { id: 1 }
    assert_redirected_to admin_messages_path
  end

  test "edit sent message" do
    message = messages(:two)
    get :edit, { id: message.id }
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
  end

  test "edit valid message" do
    message = messages(:one)
    get :edit, { id: message.id }
    assert_response :success
    assert_template :edit
    assert_equal message, assigns(:message)
  end

  test "update sent message" do
    message = messages(:two)
    patch :update, { id: message.id, message: { subject: 'test' }}
    assert_not_equal 'test', Message.find(message.id).subject
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
  end

  test "update with wrong parameters" do
    message = messages(:one)
    patch :update, { id: message.id, message: { subject: '', text: '' }}
    assert_response :success
    assert_template :edit
    assert_equal message, assigns(:message)
    assert_select '.message_subject.has-error .help-block'
    assert_select '.message_text.has-error .help-block'
  end

  test "update with valid parameters" do
    message = messages(:one)
    date = message.date
    patch :update, { id: message.id, message: { subject: 'test', text: 'bla' }}
    message = Message.find(message.id)
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
    assert_equal 'test', message.subject
    assert_equal 'bla', message.text
    assert_not_equal date, message.date
    assert message.draft?
    assert_not message.sent?
    assert_equal assigns(:current_user), message.user
  end

  test "update with invalid parameters" do
    old = messages(:one)
    date = 2.minutes.ago
    patch :update, { id: old.id, message: { date: date, state: 1, user: users(:max) }}
    new = Message.find(old.id)
    assert_not_equal date, new.date
    assert new.draft?
    assert_not new.sent?
    assert_equal assigns(:current_user), new.user
  end

  test "show new message form" do
    get :new
    assert_response :success
    assert_template :new
    assert assigns(:message)
  end

  test "create message" do
    assert_difference 'Message.all.count', +1 do
      post :create, { message: { subject: 'test', text: 'bla' }}
    end
    message = Message.all.last
    assert_redirected_to admin_message_path(message)
    assert_equal 'test', message.subject
    assert_equal 'bla', message.text
    assert_equal assigns(:current_user), message.user
    assert message.date <= DateTime.now
    assert message.date > 1.minute.ago
    assert message.draft?
    assert_not message.sent?
  end

  test "create message with error" do
    assert_no_difference 'Message.all.count' do
      post :create, { message: { subject: '', text: '' }}
    end
    assert_response :success
    assert_template :new
    assert_select '.message_subject.has-error .help-block'
    assert_select '.message_text.has-error .help-block'
  end

  test "deleting message" do
    message = messages(:one)
    delete :destroy, { id: message.id }
    assert_redirected_to admin_messages_path
    assert_not Message.find_by(id: message.id)
  end

  test "deleting invalid message" do
    delete :destroy, { id: 1 }
    assert_redirected_to admin_messages_path
  end

  test "deleting sent message" do
    message = messages(:two)
    delete :destroy, { id: message.id }
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
    assert_equal message, Message.find(message.id)
  end

  test "sending sent email" do
    message = messages(:two)
    get :mail, { id: message.id }
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
  end

  test "sending invalid email" do
    get :mail, { id: 1 }
    assert_redirected_to admin_messages_path
  end

  test "sending valid email" do
    message = messages(:one)

    emails = Server.all.map(&:email).uniq
    assert_difference 'ActionMailer::Base.deliveries.size', +emails.size do
      get :mail, { id: message.id }
    end
    ActionMailer::Base.deliveries.each do |mail|
      assert_includes emails, mail.to.first
    end

    message = Message.find(message.id)
    assert_response :success
    assert_template :show
    assert_equal message, assigns(:message)
    assert message.sent?
    assert_not message.draft?
  end

end
