require 'ostruct'

# This controller allows a superadministrator to edit server-specific settings.

class Admin::SettingsController < Admin::AdminController

  # Only superadministrators are allowed to proceed.
  before_action :require_root

  # ============================================================================

  # Shows all settings to the user and allows editing them.
  def index
    get_settings
  end

  # Saves changes made by the user and displays the new settings.
  def update
    # Save general settings directly
    settings = params[:settings].slice(:domain, :redis, :email_server,
      :email_port, :email_username, :email_email, :email_name, :timezone)
    SettingsHelper.setHash(settings)

    # The password is only saved if it is not equal to the encoded one sent to
    #    the client earlier.
    pw = params[:settings][:email_password]
    pw.nil? or pw == password_placeholder or
      SettingsHelper.set(:email_password, pw)

    # Reload the settings.
    get_settings
    render :index
  end

  # ============================================================================

  private

  # Loads all settings and constructs an object for sending to the browser.
  def get_settings
    settings = SettingsHelper.getHash.slice(:domain, :redis, :email_server,
      :email_port, :email_username, :email_email, :email_name, :timezone)
    @settings = OpenStruct.new(settings)
    @settings.email_password = password_placeholder
  end

  # Generates a placeholder for the password with the same length of the current
  #    one. This is used to send the user a hint about the currently set
  #    password (i.e. the length). This way the actual password is never sent to
  #    the user.
  def password_placeholder
    " " * SettingsHelper.get(:email_password).size
  end

end
