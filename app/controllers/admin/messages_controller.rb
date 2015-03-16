# Administrative interface for sending messages.

class Admin::MessagesController < Admin::AdminController

  # Lists all sent and not-sent messages.
  def index
    @messages = Message.all.order(date: :desc)
  end

end
