# One controller to rule them all.

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Get information about the currently selected user/server
  before_action :parse_session

  # Fire up the setup, if it should be needed (see below).
  before_action :require_setup

  # ============================================================================

  protected

  # Log the current user/server out a.k.a. destroy the session.
  def logout
    session[:user_id] = session[:server_id] = nil
  end

  # Resets the variable telling the view that a user/server is currently logged
  #    in. This prevents content in the views that shouldn't be displayed to a
  #    freshly logged out user from showing up.
  def destroy_currents
    @current_user = @current_server = nil
  end

  # ============================================================================

  private

  # Get the currently logged in user and server by their saved id and also
  #    determine all servers that the server can change to "on the fly".
  def parse_session
    @current_user ||= User.find_by(id: session[:user_id])
    @current_server ||= Server.find_by(id: session[:server_id])

    # As default: all siblings of the server are allowed. But if the user is an
    #    administrator and happen to simulate another server, display the
    #    servers assigned to that (administrative) user so he can switch back
    #    easily.
    @other_servers ||= @current_server.try(:siblings)
    @current_user.try(:servers).try do |servers|
      @other_servers = servers.to_a unless servers.include?(@current_server)
    end
  end

  # Only allow registered users past this point. Stronger than allowing only
  #    servers (see below).
  def require_user
    require_server and !@current_user and redirect_to root_path
  end

  # Only allow registered servers past this point.
  def require_server
    @current_server and return true
    render 'sessions/new', layout: 'application' and false
  end

  # If no user is found, the setup should be initiated. This is handled here.
  def require_setup
    User.any? or redirect_to setup_path(:authenticate)
  end

end
