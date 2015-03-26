# The messages are send to the servers and stored for later reference.

class Message < ActiveRecord::Base

  # Each message has an author.
  belongs_to :user
  validates :user, presence: true

  # Subject, text and author must be given. Else the message wouldn't make much
  #    sense, would it?
  validates :subject, :text, presence: true

  # The state indicates, if the message was already sent.
  enum state: [ :draft, :sent ]
  validates :state, presence: true

  # This message is sent to a set number of servers which can be specified by
  #    the sender.
  has_and_belongs_to_many :servers

  # ============================================================================

  # Renders the content of the message as html.
  def as_html(server)
    RDiscount.new(parse_text(server)).to_html.html_safe
  end

  # Renders the content of the message as plain text.
  def as_text(server)
    Nokogiri::HTML(as_html(server)).text
  end

  # Retrieve a list of servers where duplicated emails (siblings) are removed.
  def to
    servs = servers
    servs.size.times do |i|
      break if i >= servs.size
      servs -= servs[i].siblings
    end
    servs
  end

  # :nodoc:
  def to_s
    subject
  end

  # ============================================================================

  private

  # Replaces keywords in the message with usable substitutes.
  def parse_text(server)
    url = "#{SettingsHelper.get(:domain)}/login/" +
      "#{server.user ? server.email : server.seed}"
    login = '[%{url}](%{url})' % { url: url }
    text % { firstname: server.firstname, login: login }
  end

end
