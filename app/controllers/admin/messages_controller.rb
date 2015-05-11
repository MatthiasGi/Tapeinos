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
    begin
      @message = Message.new(message_params)
      @message.update(date: DateTime.now, user: @current_user) and
        return redirect_to admin_message_path(@message)
    rescue ActiveRecord::RecordNotFound
      @message ||= Message.new
    end
    render :new
  end

  # Lists all sent and not-sent messages.
  def index
    @messages = Message.all
  end

  # Shows a single, specific message.
  def show; end

  # Shows a form for editing messages.
  def edit; end

  # Saves updates on the given message.
  def update
    begin
      @message.update(message_params) or return render :edit
    rescue ActiveRecord::RecordNotFound
      return render :edit
    end
    @message.update(date: DateTime.now, user: @current_user)
    render :show
  end

  # Destroys a message.
  def destroy
    @message.destroy
    redirect_to admin_messages_path
  end

  # Actually sends a message, which [old version: requires quite a few steps] is
  #    now simpler than ever!
  def mail
    if @message.to.empty?
      flash.now[:no_server] = true
      return render :edit
    end

    MessageMailerSenderJob.perform_later(@message)
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
    params.require(:message).permit(:subject, :text, :plan_id, server_ids: [])
  end

end
