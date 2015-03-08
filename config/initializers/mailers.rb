# Be sure to restart your server when you modify this file.

Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = {
  address: 'smtp.gmail.com',
  port: 587,
  user_name: ENV['GMAIL_USERNAME'],
  password: ENV['GMAIL_PASSWORD'],
  authentication: :plain,
  enable_starttls_auto: true
}
