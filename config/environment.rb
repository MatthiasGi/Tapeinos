# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Load enviromental variables
Rails.application.config.before_configuration do
  env_file = File.join(Rails.root, 'config', 'local_env.yml')
  YAML.load(File.open(env_file)).each do |key, value|
    ENV[key.to_s] = value
  end if File.exists?(env_file)
end

# Initialize the Rails application.
Rails.application.initialize!
