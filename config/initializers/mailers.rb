# Be sure to restart your server when you modify this file.

# This loads the saved settings for sending mails.
Rails.application.config.action_mailer.delivery_method = :smtp unless Rails.env.test?
Rails.application.config.action_mailer.smtp_settings = {
  address: SettingsHelper.get(:email_server, 'smtp.google.com'),
  port: SettingsHelper.get(:email_port, 587).to_i,
  user_name: SettingsHelper.get(:email_username),
  password: SettingsHelper.get(:email_password),
  authentication: :plain,
  enable_starttls_auto: true
}
