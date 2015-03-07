# One mailer to rule them all.

class ApplicationMailer < ActionMailer::Base
  default from: ENV['GMAIL_USERNAME']
  layout 'mailer'
end
