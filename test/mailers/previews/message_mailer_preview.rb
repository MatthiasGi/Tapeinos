# Preview all emails at http://localhost:3000/rails/mailers/message_mailer
class MessageMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/message_mailer/global_mail
  def global_mail
    server = Server.all.first
    text = "**Test** %{firstname}\n\n %{login}"
    MessageMailer.global_mail('Testsubject', server, text)
  end

end
