require 'test_helper'

class MessageMailerTest < ActionMailer::TestCase

  def setup
    @subject = "Testsubject"
    @text = "**Test** %{firstname}\n\n %{login}"
  end

  test "global_mail" do
    server = servers(:max)
    mail = MessageMailer.global_mail(@subject, server, @text)
    assert_equal @subject, mail.subject
    assert_equal [server.email], mail.to
    assert_equal [ENV['GMAIL_USERNAME']], mail.from
    assert_match server.firstname, mail.body.encoded
    url = ENV['BASE_URL'] + '/login/' + server.seed
    assert_match url, mail.body.encoded
  end

end
