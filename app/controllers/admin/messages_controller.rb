# Administrative interface for sending messages.

class Admin::MessagesController < Admin::AdminController

  # Gets the selected message for all actions that need exactly one.
  before_action :get_message, except: :index

  # ============================================================================

  # Lists all sent and not-sent messages.
  def index
    @messages = Message.all.order(date: :desc)
  end

  # Shows a single, specific message.
  def show; end

  # ============================================================================

  private

  # Ensures that a message is selected and determines it.
  def get_message
    @message = Message.find_by(id: params[:id])
    @message or redirect_to admin_messages_path
  end

end
