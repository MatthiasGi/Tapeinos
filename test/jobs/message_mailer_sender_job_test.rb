require 'test_helper'

class MessageMailerSenderJobTest < ActiveJob::TestCase

  def setup
    @job = MessageMailerSenderJob.new
    ActionMailer::Base.deliveries.clear
  end

  test "automagically sending messages to all servers" do
    servs = [ servers(:max), servers(:max2), servers(:heinz), servers(:heinz2) ]
    servers_result = [ servers(:max), servers(:heinz) ]
    message = messages(:one)
    assert message.update(servers: servs)

    assert_difference 'ActionMailer::Base.deliveries.size', +2 do
      @job.perform(message)
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
      @job.perform(message)
    end
  end

  test "sending message associated with plan" do
    message = messages(:with_plan)
    assert message.update(servers: Server.all)
    emails = Server.all.map(&:email).uniq
    assert_difference 'ActionMailer::Base.deliveries.size', emails.size do
      @job.perform(message)
    end
    ActionMailer::Base.deliveries.each do |mail|
      assert_match "#{message.plan.title}.pdf", mail.attachments.first.to_s
    end
  end

end
