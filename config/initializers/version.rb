# This asks git for a current version and updates it inside a file for later
#    reference (see: http://stackoverflow.com/a/15675188).

# Only attempt update on local machine.
if Rails.env.development?
  # Update version file from latest git tag.
  File.open('config/version', 'w') do |file|
    file.write `git describe --tags --always`
  end
end

# Load current version.
Rails.application.config.version = File.read('config/version')