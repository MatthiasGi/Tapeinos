# Preview all emails at http://localhost:3000/rails/mailers/server_mailer
class ServerMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/server_mailer/seed_generated_mail
  def seed_generated_mail
    server = Server.new({ email: 'test@bla.de', seed: '12345678901234567890123456789012' })
    ServerMailer.seed_generated_mail(server)
  end

end
