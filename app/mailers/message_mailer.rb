# This mailer sends a general messages, typed by an administrator, to a specific
#    server.

class MessageMailer < ApplicationMailer

  # Sends a custom email by an administrator to the selected server.
  def global_mail(server, message)
    @html = message.as_html(server)
    @text = message.as_text(server)
    mail to: server.email, subject: message.subject
  end

end
