require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "forgot_password mail" do
    user = users(:max)
    user.prepare_password_reset
    mail = UserMailer.forgot_password_mail(user)
    assert_equal I18n.t('user_mailer.forgot_password_mail.subject'), mail.subject
    assert_equal [user.email], mail.to
    assert_equal [ENV['GMAIL_USERNAME']], mail.from
    url = ENV['BASE_URL'] + '/forgot-password/' + user.password_reset_token
    assert_match url, mail.body.encoded
  end

  test "password changed mail" do
    user = users(:max)
    mail = UserMailer.password_changed_mail(user)
    assert_equal I18n.t('user_mailer.password_changed_mail.subject'), mail.subject
    assert_equal [user.email], mail.to
    assert_equal [ENV['GMAIL_USERNAME']], mail.from
  end

  test "user created mail" do
    user = users(:max)
    mail = UserMailer.user_created_mail(user, 'testen')
    assert_equal I18n.t('user_mailer.user_created_mail.subject'), mail.subject
    assert_equal [user.email], mail.to
    assert_equal [ENV['GMAIL_USERNAME']], mail.from
  end

end
