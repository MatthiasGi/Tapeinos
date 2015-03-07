# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/forgot_password_mail
  def forgot_password_mail
    user = User.new({ password_reset_token: 'testtoken' })
    UserMailer.forgot_password_mail(user)
  end

end
