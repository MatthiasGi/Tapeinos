# This mailer is used to send out mails regardin user-administration.

class UserMailer < ApplicationMailer

  # Sends an email to a user, that wants to reset his password. The subject is
  #    set via de.user_mailer.forgot_password_mail.subject.
  def forgot_password_mail(user)
    @forgot_password_link = ENV['BASE_URL'] + '/forgot-password/' +
      user.password_reset_token
    mail to: user.email
  end

end
