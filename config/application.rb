require_relative 'boot'

require 'rails/all'

# Required for loading settings on startup.
require './app/helpers/settings_helper'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tapeinos
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = SettingsHelper.get(:timezone, 'UTC')

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :de

    # Use sidekiq as ActiveJob-Backend.
    config.active_job.queue_adapter = :sidekiq

    # Loads images from the vendor-folder into the assets-pipeline.
    config.assets.paths << Rails.root.join("vendor", "assets", "images")

    # Loads the lib-folder which contains helper-classes that don't really fit into the app-folder.
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
