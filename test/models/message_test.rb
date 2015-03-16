require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  def setup
    @subject = { subject: 'Testsubject' }
    @text = { text: "**Test** %{firstname}\n\n %{login}" }
    @author = { user: users(:max) }
    @state = { state: :sent }
    @all = { **@subject, **@text, **@author, **@state }
  end

  test "mandatory fields subject, text, author and state given" do
    message = Message.new(**@subject, **@author, **@state)
    assert_not message.valid?, "No text given"
    message = Message.new(**@subject, **@text, **@state)
    assert_not message.valid?, "No author given"
    message = Message.new(**@text, **@author, **@state)
    assert_not message.valid?, "No subject given"
    message = Message.new(**@text, **@subject, **@author)
    assert message.valid?, "State is optional as it has a default"
    assert message.draft?
    message = Message.new(@all)
    assert message.valid?, "Everything mandatory given, but still not valid?"
    assert_equal 'Testsubject', message.subject
    assert_equal @text[:text], message.text
    assert_equal users(:max), message.user
    assert message.sent?
  end

  test "invalid author" do
    message = Message.new(**@subject, **@text, user_id: 1)
    assert_not message.valid?
  end

end
