require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "forgot_password_mail" do
    user = users(:max)
    user.prepare_password_reset
    mail = UserMailer.forgot_password_mail(user)
    assert_equal "Tapeinos - Passwort vergessen", mail.subject
    assert_equal [user.email], mail.to
    assert_equal [ENV['GMAIL_USERNAME']], mail.from
    url = ENV['BASE_URL'] + '/forgot-password/' + user.password_reset_token
    assert_match url, mail.body.encoded
  end

end
