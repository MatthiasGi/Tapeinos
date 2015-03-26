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
  end

  test "global mail for user" do
    server = servers(:max)
    message = messages(:one)
    mail = MessageMailer.global_mail(server, message)
    assert_match server.firstname, mail.body.encoded
    url = SettingsHelper.get(:domain) + '/login/' + server.user.email
    assert_match url, mail.body.encoded
  end

  test "static method for automagically sending messages to all server" do
    servs = [ servers(:max), servers(:max2), servers(:heinz), servers(:heinz2) ]
    servers_result = [ servers(:max), servers(:heinz) ]
    message = messages(:one)
    assert message.update(servers: servs)
    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      MessageMailer.send_message(message)
    end
    links = [ servers(:max).email, servers(:heinz).seed ]

    to = servers_result
    ActionMailer::Base.deliveries.last(2).each_with_index do |mail, i|
      server = servers_result[i]
      assert_includes to, server
      to -= [ server ]
      assert_equal 'Testsubject 1', mail.subject
      assert_equal [server.email], mail.to
      assert_equal [SettingsHelper.get(:email_email)], mail.from
      assert_match server.firstname, mail.body.encoded
      url = SettingsHelper.get(:domain) + '/login/' + links[i]
      assert_match url, mail.body.encoded
    end

    assert_equal [], to
  end

  test "sending message to noone" do
    message = messages(:one)
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      MessageMailer.send_message(message)
    end
  end

end
