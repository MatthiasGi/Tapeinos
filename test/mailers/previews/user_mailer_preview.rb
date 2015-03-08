# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/forgot_password_mail
  def forgot_password_mail
    user = User.new({ password_reset_token: 'testtoken' })
    UserMailer.forgot_password_mail(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_changed_mail
  def password_changed_mail
    user = User.new({ email: 'test@bla.de' })
    UserMailer.password_changed_mail(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/user_created_mail
  def user_created_mail
    user = User.new({ email: 'test@bla.de' })
    UserMailer.user_created_mail(user, 'blabla')
  end

end
