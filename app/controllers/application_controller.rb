# One controller to rule them all.

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # ============================================================================

  protected

  # Log the current user out a.k.a. destroy the session.
  def logout
    session[:user_id] = nil
  end
end
