# One controller to rule them all.

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Require all users to be logged in.
  before_action :current_user
  before_action :require_login

  # ============================================================================

  protected

  # Log the current user out a.k.a. destroy the session.
  def logout
    session[:user_id] = nil
  end

  # ============================================================================

  private

  # Get the currently logged in user by his saved id.
  def current_user
    @current_user = User.find_by(id: session[:user_id])
  end

  # Only allow registered users past this point.
  def require_login
    render 'sessions/new' unless @current_user
  end

end
