source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.0.0', '< 5.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '>= 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '>= 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '>= 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '>= 3.1.7'

# Use Haml (with markdown-support) as template engine
gem 'haml'
gem 'redcarpet'

# Bootstrap helpers make using Twitter's Bootstrap easier
gem 'bootstrap-sass'
gem 'bh'

# Use Simple Form to create simple forms and chosen for simple, cocoon for complex associations
gem 'simple_form'
gem 'cocoon'
gem 'chosen-rails'

# This provides a custom datetimepicker for fallack reasons
gem 'momentjs-rails'
gem 'bootstrap3-datetimepicker-rails'

# Sidekiq handles delayed jobs (e.g. sending mails later)
gem 'sidekiq'

# Wicked allows easy creation of multi-step wizards.
gem 'wicked'

# Creation of pdfs for plans.
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

# Determines the easter-date. Why reinvent the wheel?
gem 'date_easter'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '>= 2.0'

  # ERD helps to visualize the models and their relations to keep track of them.
  gem "rails-erd"

  # File watcher needs this gem (see https://stackoverflow.com/a/42514900/6160723).
  gem 'listen'
end

group :test do
  # Assigns has been extracted to a gem.
  gem 'rails-controller-testing'
end
