# This helper is full of static methods for loading, reading and writing
#    application-wide settings.

module SettingsHelper

  # Gets a setting and returns the default value if (and only if) the setting
  #    could not be found.
  def self.get(key, default = nil)
    value = settings[key.to_sym]
    value.nil? ? default : value
  end

  # Sets a setting and saves it to the settings-file.
  def self.set(key, value)
    config = settings
    config[key.to_sym] = value
    File.open(file, 'w') do |h|
      h.write(config.to_yaml)
    end
  end

  # ============================================================================

  private

  # Shortcut for accessing the saved settings.
  def self.settings
    File.exists?(file) and YAML.load_file(file) or {}
  end

  # Shortcut for using the settings-file.
  def self.file
    "config/settings.#{Rails.env}.yml"
  end

end
