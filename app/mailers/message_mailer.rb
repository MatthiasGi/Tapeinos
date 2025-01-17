# This mailer sends a general messages, typed by an administrator, to a specific
#    server.

class MessageMailer < ApplicationMailer

  # Sends a custom email by an administrator to the selected server and attaches a ready-to-use pdf-plan (if given).
  def global_mail(server, message, plan = nil)
    @html = message.as_html(server)
    @text = message.as_text(server)

    plan and attachments["#{message.plan.title}.pdf"] = plan
    mail to: server.email, subject: message.subject
  end

end
