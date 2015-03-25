# One mailer to rule them all.

class ApplicationMailer < ActionMailer::Base
  default from: SettingsHelper.get(:email_email)
  layout 'mailer'
end
