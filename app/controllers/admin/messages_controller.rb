# Administrative interface for sending messages.

class Admin::MessagesController < Admin::AdminController

  # Gets the selected message for all actions that need exactly one.
  before_action :get_message, except: [ :new, :create, :index ]

  # Already sent emails should not be edited, deleted or sent again: they are
  #    here for documentation pruposes.
  before_action :exclude_sent, only: [ :edit, :update, :destroy, :mail ]

  # ============================================================================

  # Offers a form for creating new messages.
  def new
    @message = Message.new
  end

  # Actually creates the new message.
  def create
    @message = Message.new(message_params)
    @message.update(date: DateTime.now, user: @current_user) and
      return redirect_to admin_message_path(@message)
    render :new
  end

  # Lists all sent and not-sent messages.
  def index
    @messages = Message.order(date: :desc)
  end

  # Shows a single, specific message.
  def show; end

  # Shows a form for editing messages.
  def edit; end

  # Saves updates on the given message.
  def update
    @message.update(message_params) or return render :edit
    @message.update(date: DateTime.now, user: @current_user)
    render :show
  end

  # Destroys a message.
  def destroy
    @message.destroy
    redirect_to admin_messages_path
  end

  # Actually sends a message, which requires quite a few steps.
  def mail

    # Determine all servers which get an email but subtract similar ones, so one
    #    address does not get five emails.
    servers = Server.all
    servers.size.times do |i|
      break if i >= servers.size
      servers -= servers[i].siblings
    end

    # Now sent a message to each server.
    servers.each do |server|
      MessageMailer.global_mail(server, @message).deliver_later
    end

    # Mark the message as sent and display the updated show-enviroment.
    @message.sent!
    render :show
  end

  # ============================================================================

  private

  # Ensures that a message is selected and determines it.
  def get_message
    @message = Message.find_by(id: params[:id])
    @message or redirect_to admin_messages_path
  end

  # Already sent messages are excluded from some actions (see above)
  def exclude_sent
    @message.sent? and return render :show
  end

  # Strong-parameters strong at work.
  def message_params
    params.require(:message).permit(:subject, :text)
  end

end
