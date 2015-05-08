# Be sure to restart your server when you modify this file.

# Set redis server and port (set by root).
redis = SettingsHelper.get(:redis, 'redis://localhost:6379')
Sidekiq.configure_server { |config| config.redis = { url: redis } }
Sidekiq.configure_client { |config| config.redis = { url: redis } }

if Rails.env.production?
  # Check, if redis is up.
  redis_down = false
  info = Sidekiq.redis { |conn| conn.info } rescue redis_down = true
  redis_down ||= !info.present?
  SettingsHelper.set(:redis_down, redis_down)
  puts "ERROR! Redis is not running on set location #{redis}!" if redis_down

  # Check, if sidekiq is running.
  require 'sidekiq/api'
  sidekiq_down = false
  sidekiq_down = Sidekiq::ProcessSet.new.size <= 0 rescue sidekiq_down = true
  SettingsHelper.set(:sidekiq_down, sidekiq_down)
  puts 'ERROR! Sidekiq is not running!' if sidekiq_down

  # Get active queues
  sidekiq_mailer_up = false
  unless sidekiq_down
    Sidekiq::ProcessSet.new.each do |process|
      sidekiq_mailer_up = process['queues'].include? 'mailers' unless sidekiq_mailer_up
    end
  end
  SettingsHelper.set(:sidekiq_mailer_down, !sidekiq_mailer_up)
  puts 'ERROR! Sidekiq-server has no active mailer-queue!' unless sidekiq_mailer_up
end

# Reset restart-controller
SettingsHelper.set(:restart_required, false)
