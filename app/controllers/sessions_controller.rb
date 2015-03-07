# The session controller handles everything regarding login and logout of users.

class SessionsController < ApplicationController

  # Automatically clean the session while logging in.
  before_action :logout

  # Remove currently logged in user and server (see below) when creating new
  #    sessions.
  before_action :destroy_currents, only: [ :new, :create, :temporary ]

  # ============================================================================

  # Display a login form.
  def new; end

  # Actually create the new session.
  def create

    # Get the entered email and try to find a user.
    email = params[:user][:email]
    @user = User.find_by(email: email)

    if @user.nil?

      # If no user was found, the email was incorrect.
      @user = User.new(email: email)
      @user.errors.add(:email, t('.email_not_found'))

    elsif @user.blocked?

      # The user is blocked because of to many failed authentication-attempts.
      flash.now[:blocked] = true

    elsif not @user.authenticate(params[:user][:password])

      # The password was wrong, inform the user.
      @user.failed_authentication
      @user.errors.add(:password, t('.password_wrong'))

    elsif @user.servers.empty?

      # The user has no server, so there's no point in logging him in.
      flash.now[:no_server_available] = true

    else

      # The user could be authenticated successfully and a server can be
      #    registered.
      @user.clear_password_reset
      @user.used
      session[:user_id] = @user.id

      # Save the first available server of the user as currently logged in.
      session[:server_id] = @user.servers.first.id

      # Allow entrance for the user
      return redirect_to root_path

    end

    # Render the login-form with errors.
    render :new

  end

  # Allows changing the currently selected server.
  def update
    server = Server.find_by(id: params[:id])

    # The change is allowed, if new and old server are the same, or the current
    #    server is allowed to change to the new one (checked by the model).
    if server and @current_server and @current_server == server or
        @current_server.siblings.include?(server)
      session[:server_id] = server.id
      redirect_to :back
    else
      flash.now[:invalid_server_change] = true
      @user = @current_user
      destroy_currents
      render :new
    end
  end

  # Destroy the current session a.k.a. log the user out.
  def destroy
    @user = @current_user
    flash.now[:logout] = @current_server
    destroy_currents
    render :new
  end

  # Creates a temporary session for a server that is not linked with a user.
  def temporary
    server = Server.find_by(seed: params[:seed])

    if server.nil?
      flash.now[:invalid_seed] = true
    elsif server.user
      flash.now[:server_has_account] = true
      @user = server.user
    else
      session[:server_id] = server.id
      return redirect_to root_path
    end

    render :new
  end

  # ============================================================================

  private

  # Resets the variable telling the view that a user/server is currently logged
  #    in. This prevents content in the views that shouldn't be displayed to a
  #    freshly logged out user from showing up.
  def destroy_currents
    @current_user = @current_server = nil
  end

end
