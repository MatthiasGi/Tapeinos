# The session controller handles everything regarding login and logout of users.

class SessionsController < ApplicationController

  # Automatically clean the session while logging in.
  before_action :logout, only: [:new, :create]

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

    elsif @user.authenticate(params[:user][:password])

      # The user could be authenticated successfully.
      @user.clear_password_reset
      @user.used
      session[:user_id] = @user.id
#      redirect_to root_path #TODO

    else

      # The password was wrong, inform the user.
      @user.failed_authentication
      @user.errors.add(:password, t('.password_wrong'))

    end

    # Render the login-form with errors.
    render :new

  end

  # Destroy the current session a.k.a. log the user out.
  def destroy
    @user = User.find_by(id: session[:user_id])
    logout
    flash.now[:logout] = true if @user
    render :new
  end

end
