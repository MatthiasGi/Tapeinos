# This controller allows a superadministrator to edit server-specific settings.

class Admin::SettingsController < Admin::AdminController

  # This controller allows the user to change the settings from within the
  #    administrative interface.
  include AdjustsSettings

  # Only superadministrators are allowed to proceed.
  before_action :require_root

  # ============================================================================

  # Shows all settings to the user and allows editing them.
  def index
    get_settings
  end

  # Saves changes made by the user and displays the new settings.
  def update
    # Save the settings via the concern.
    save_settings

    # Reload the settings.
    get_settings
    render :index
  end

end
