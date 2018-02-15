require 'test_helper'

class ServerMailerTest < ActionMailer::TestCase

  test "new seeds generated mail" do
    server = servers(:heinz)
    mail = ServerMailer.seed_generated_mail(server)
    assert_equal I18n.t('server_mailer.seed_generated_mail.subject'), mail.subject
    assert_equal [ server.email ], mail.to
    assert_equal [ SettingsHelper.get(:email_email) ], mail.from
    url = SettingsHelper.get(:domain) + '/login/' + server.seed
    assert_match url, mail.body.encoded
  end

end
