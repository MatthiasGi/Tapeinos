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

end
