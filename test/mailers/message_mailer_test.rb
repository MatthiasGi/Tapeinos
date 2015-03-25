require 'test_helper'

class MessageMailerTest < ActionMailer::TestCase

  def setup
    @subject = "Testsubject"
    @text = "**Test** %{firstname}\n\n %{login}"
  end

  test "global_mail" do
    server = servers(:heinz)
    message = messages(:one)
    mail = MessageMailer.global_mail(server, message)
    assert_equal 'Testsubject 1', mail.subject
    assert_equal [server.email], mail.to
    assert_equal [SettingsHelper.get(:email_email)], mail.from
    assert_match server.firstname, mail.body.encoded
    url = SettingsHelper.get(:domain) + '/login/' + server.seed
    assert_match url, mail.body.encoded
  end

  test "global mail for user" do
    server = servers(:max)
    message = messages(:one)
    mail = MessageMailer.global_mail(server, message)
    assert_match server.firstname, mail.body.encoded
    url = SettingsHelper.get(:domain) + '/login/' + server.user.email
    assert_match url, mail.body.encoded
  end

end
