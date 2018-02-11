# The session controller handles everything regarding login and logout of users.

class SessionsController < ApplicationController

  # Automatically clean the session while logging in.
  before_action :logout

  # Remove currently logged in user and server (see below) when creating new
  #    sessions.
  before_action :destroy_currents, only: [ :new, :create, :temporary ]

  # ============================================================================

  # Display a login form. If an email is provided, try to get the user or assume
  #    which server tried to login by this way.
  def new
    email = params[:email] or return
    @user = User.find_by(email: email) and return
    Server.find_by(email: email) and flash.now[:server_has_no_account] = true
  end

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

    elsif @user.servers.empty? and not @user.administrator?

      # The user has no server, so there's no point in logging him in.
      flash.now[:no_server_available] = true

    else

      # The user could be authenticated successfully and a server can be
      #    registered.
      @user.clear_password_reset
      @user.used
      session[:user_id] = @user.id

      if @user.servers.empty?

        # The user must be an administrator as he has no servers (not an
        #     administrator was catched beforehand). So redirect him directly to
        #     the administrative interface.
        return redirect_to admin_servers_path
        
      else

        # Save the first available server of the user as currently logged in.
        server = @user.servers.first
        session[:server_id] = server.id
        server.used

        # Allow entrance for the user
        return redirect_to root_path

      end

    end

    # Render the login-form with errors.
    render :new

  end

  # Allows changing the currently selected server.
  def update

    # Determine the new server and user if possible. If that isn't allowed it
    #    will be reset later (below).
    server = Server.find_by(id: params[:id])
    session[:server_id] = server.try(:id)
    session[:user_id] = @current_user.try(:id)

    if server and @current_user.try(:administrator?) and
        @current_user.try(:servers).try(:exclude?, server)
      # An administrator is changing to a server that doesn't belong to him.
      redirect_to root_path
    elsif @current_server == server or
        @current_server.try(:siblings).try(:include?, server) or
        @current_user.try(:servers).try(:include?, server)
      # The server is the same or a server is changing to another server that is
      #    related to him.
      server.used
      redirect_back fallback_location: plans_path
    else
      # The change is not allowed, abort everything
      flash.now[:invalid_server_change] = true and logout
      @user = @current_user and destroy_currents
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
      server.used
      return redirect_to root_path
    end

    render :new
  end

end
