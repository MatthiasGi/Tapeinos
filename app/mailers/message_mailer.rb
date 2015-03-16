# This mailer sends a general messages, typed by an administrator, to a specific
#    server.

class MessageMailer < ApplicationMailer

  # Sends a custom email by an administrator to the selected server.
  def global_mail(subject, server, text)
    url = ENV['BASE_URL'] + '/login/' + server.seed
    login = '[%{url}](%{url})' % { url: url }
    text = text % { firstname: server.firstname, login: login }

    @html = RDiscount.new(text).to_html.html_safe
    @text = Nokogiri::HTML(@html).text

    mail to: server.email, subject: subject
  end

end
