class SettingsController < ApplicationController

  # The servers overview should be only available if the user has any servers.
  before_action :only_server, only: [ :servers, :servers_update ]

  # The security-page is for changing the seed for logging in without users. So
  #    there is no point in showing this to a user.
  before_action :only_server_without_user, only: [ :security ]

  # Only a user can modify his login-information or delete itself. A server
  #    couldn't handle that.
  before_action :only_user, only: [ :data, :data_update, :delete, :delete_do ]

  # Always assemble the list of displayable menu-entries.
  before_action :check_displays

  # Creates the array that contains all relevant servers.
  before_action :assemble_servers, only: [ :servers, :servers_update, :security_do ]

  # ============================================================================

  # Show all servers that are either managed by the current user or associated
  #    with the current server.
  def servers; end

  # Save the information about the servers mentioned above.
  def servers_update
    servers_params = params.require(:user).require(:servers)
    servers = @servers

    # Throw invalid servers out of editing business.
    servers_params.select! do |k, v|
      servers.map(&:id).map(&:to_s).include? k
    end

    # Only allow specific attributes
    attributes = servers_params.values.map { |h| h.slice(:size_talar, :size_rochet) }

    # Batch-apply changes
    @servers = Server.update(servers_params.keys, attributes)
    flash.now[:changes_saved] = @servers.map(&:errors).map(&:empty?).all?

    # Read servers if they weren't inside the request.
    @servers += servers.without(*@servers)
    render :servers
  end

  # The security-page is for letting the server gain a new seed. This may be
  #    used in cases where the seed was told another person or similar.
  def security; end

  # On clicking a button inside the security-page generate a new seed here.
  def security_do
    @servers.map(&:generate_seed)
    ServerMailer.seed_generated_mail(@servers.first).deliver_later
    flash.now[:success] = true
    render :security
  end

  # Allows a user to modify his login-data.
  def data; end

  # Saves the modified login-data of a user.
  def data_update
    user_params = params.require(:user).permit(:email, :password, :password_confirmation)
    flash.now[:changes_saved] = @current_user.update(user_params)
    render :data
  end

  # Allows a user to delete himself.
  def delete; end

  # Actually deletes the user, if the server really wishes to. Ignorant.
  def delete_do

    # Block the deletion if the user is the last available root
    if @current_user.root? and User.where(role: :root).count <= 1
      flash.now[:cant_delete_last_root] = true
      return render :delete
    end

    # Gather all linked servers.
    servers = @current_user.servers
    @current_user.destroy

    # If there are any servers generate new seeds (security and such) and
    #    provide them with a new login-method.
    if servers.any?
      servers.map(&:generate_seed)
      UserMailer.user_deleted_mail(servers.first).deliver_later
    end

    # Display the login-page with a corresponding message.
    flash.now[:user_deleted] = true
    request_login
  end

  # ============================================================================

  private

  # Creates an array with all concerning servers associated to the current one.
  def assemble_servers
    @servers = @current_server.siblings << @current_server
  end

  # This function collects information about whether the menu-entry should be
  #    displayed to the current user or not.
  def check_displays
    @display = {
      servers: @current_server.present?,
      security: (@current_server.present? and @current_user.nil?),
      data: @current_user.present?,
      delete: @current_user.present?
    }
    @active = action_name.split('_')[0]
  end

  # This function ensures that only a registered and logged in user is allowed
  #    to view the page. require_user from the ApplicationController doesn't
  #    apply here as the redirection is handled differently.
  def only_user
    @current_user and return true
    @current_server and return redirect_to settings_path
    request_login
  end

  # This function ensures that only a logged in server is able to view the page
  #    that is not associated with an user-account.
  def only_server_without_user
    !@current_user and @current_server and return true
    @current_user and return redirect_to @current_server ? settings_path : settings_data_path
    request_login
  end

  # This function ensures that only a logged in server is able to view the page.
  #    require_server from the ApplicationController doesn't apply here as the
  #    redirection is handled differently.
  def only_server
    @current_server and return true
    @current_user.try(:admin?) and return redirect_to settings_data_path
    request_login
  end

end
