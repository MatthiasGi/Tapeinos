# One controller to rule them all.

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Get information about the currently selected user/server
  before_action :parse_session

  # ============================================================================

  protected

  # Log the current user/server out a.k.a. destroy the session.
  def logout
    session[:user_id] = session[:server_id] = nil
  end

  # ============================================================================

  private

  # Get the currently logged in user and server by their saved id.
  def parse_session
    @current_user ||= User.find_by(id: session[:user_id])
    @current_server ||= Server.find_by(id: session[:server_id])
  end

  # Only allow registered users past this point. Stronger than allowing only
  #    servers (see below).
  def require_user
    render 'sessions/new' unless @current_user
  end

  # Only allow registered servers past this point.
  def require_server
    render 'sessions/new' unless @current_server
  end

end
