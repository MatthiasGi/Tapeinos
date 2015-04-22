# This helper is full of static methods for loading, reading and writing
#    application-wide settings.

module SettingsHelper

  # Gets a setting and returns the default value if (and only if) the setting
  #    could not be found.
  def self.get(key, default = nil)
    value = getHash[key.to_sym]
    value.nil? ? default : value
  end

  # Sets a setting and saves it to the settings-file. If the file-content was
  #    changed, it returns true, if there was no change: false.
  def self.set(key, value)
    config = getHash
    return false if config[key.to_sym] == value
    config[key.to_sym] = value
    File.open(file, 'w') do |h|
      h.write(config.to_yaml)
    end
    true
  end

  # This retrieves all settings at once.
  def self.getHash
    File.exists?(file) and YAML.load_file(file) or {}
  end

  # Sets multiple settings at once while still returning true, if any change to
  #    the file was made, otherwise it will return false.
  def self.setHash(hash)
    results = hash.map { |key, value| set(key, value) }
    results.any?
  end

  # ============================================================================

  private

  # Shortcut for using the settings-file.
  def self.file
    "config/settings.#{Rails.env}.yml"
  end

end
