require 'test_helper'

class MessageMailerTest < ActionMailer::TestCase
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!

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
    assert_empty mail.attachments
  end

  test "global mail for user" do
    server = servers(:max)
    message = messages(:one)
    mail = MessageMailer.global_mail(server, message)
    assert_match server.firstname, mail.body.encoded
    url = SettingsHelper.get(:domain) + '/login/' + server.user.email
    assert_match url, mail.body.encoded
  end

  test "global mail with plan as attachment" do
    message = messages(:with_plan)
    server = Server.first
    dummy_att = {
      mime_type: 'text/plain',
      content: 'Lorem ipsum dolor sit amet.'
    }

    mail = MessageMailer.global_mail(server, message, dummy_att)
    assert_match "#{message.plan.title}.pdf", mail.attachments.first.to_s
  end

end
