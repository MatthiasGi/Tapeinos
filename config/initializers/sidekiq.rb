# Be sure to restart your server when you modify this file.

# Set redis server and port (set by root).
redis = SettingsHelper.get(:redis, 'redis://localhost:6379')
Sidekiq.configure_server { |config| config.redis = { url: redis } }
Sidekiq.configure_client { |config| config.redis = { url: redis } }

unless Rails.env.test?
  # Check, if redis is up.
  redis_up = nil
  info = Sidekiq.redis { |conn| conn.info } rescue redis_up = false
  redis_up ||= info.present?
  SettingsHelper.set(:redis_up, redis_up)
  puts "ERROR! Redis is not running on set location #{redis}!" unless redis_up

  # Check, if sidekiq is running.
  require 'sidekiq/api'
  sidekiq_up = nil
  sidekiq_up = Sidekiq::ProcessSet.new.size > 0 rescue sidekiq_up = false
  SettingsHelper.set(:sidekiq_up, sidekiq_up)
  puts 'ERROR! Sidekiq is not running!' unless sidekiq_up

  # Get active queues
  sidekiq_queue_mailer = false
  if sidekiq_up
    Sidekiq::ProcessSet.new.each do |process|
      sidekiq_queue_mailer = process['queues'].include? 'mailer' unless sidekiq_queue_mailer
    end
  end
  SettingsHelper.set(:sidekiq_queue_mailer, sidekiq_queue_mailer)
  puts 'ERROR! Sidekiq-server has no active mailer-queue!' unless sidekiq_queue_mailer
end
