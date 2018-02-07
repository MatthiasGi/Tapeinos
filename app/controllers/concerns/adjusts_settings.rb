require 'ostruct'

# This concern allows a controller to support changing the server-settings via
#    the SettingsHelper.

module AdjustsSettings
  extend ActiveSupport::Concern

  # ============================================================================

  private

  # Retrieves all relevant settings from the saved file and stores it in an
  #    object accessable for the view and directly usable for form-helpers.
  def get_settings
    settings = SettingsHelper.getHash.slice(:domain, :redis, :email_server,
      :email_port, :email_username, :email_email, :email_name, :timezone)
    @settings = OpenStruct.new(settings)
    @settings.email_password = password_placeholder
    @settings
  end

  # Generates a string consisting only of spaces with the length of the
  #    currently saved password. This is used to mask the password.
  def password_placeholder
    " " * SettingsHelper.get(:email_password, '').size
  end

  # Saves the transmitted settings by the user.
  def save_settings
    # Save general settings at once and require restart on any changes.
    params[:settings] ||= {}
    settings = params[:settings].slice(:domain, :redis, :email_server,
      :email_port, :email_username, :email_email, :email_name, :timezone)
    SettingsHelper.setHash(settings.permit!.to_h) and
      SettingsHelper.set(:restart_required, true)

    # Only save the new password if it isn't equal the masked string or not set.
    password = params[:settings][:email_password]
    password.nil? or password == password_placeholder or
      (SettingsHelper.set(:email_password, password) and
        SettingsHelper.set(:restart_required, true))
  end

end
