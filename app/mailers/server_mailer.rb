# This mailer is used to send out mails regarding server-specific jobs.

class ServerMailer < ApplicationMailer

  # Sends an email to the server to announce the newly generated seeds.
  def seed_generated_mail(server)
    @seed_link = SettingsHelper.get(:domain) + '/login/' + server.seed
    mail to: server.email
  end
  
end
