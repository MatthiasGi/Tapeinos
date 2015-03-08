# This mailer is used to send out mails regardin user-administration.

class UserMailer < ApplicationMailer

  # Sends an email to a user, that wants to reset his password. The subject is
  #    set via de.user_mailer.forgot_password_mail.subject.
  def forgot_password_mail(user)
    @forgot_password_link = ENV['BASE_URL'] + '/forgot-password/' +
      user.password_reset_token
    mail to: user.email
  end

  # This email should be send if a password was changed. It notifies the user of
  #    a perhaps unwanted change.
  def password_changed_mail(user)
    mail to: user.email
  end

  # If a new user is created, he receives his new password by mail.
  def user_created_mail(user, password)
    @email = user.email
    @password = password
    mail to: @email
  end

end
