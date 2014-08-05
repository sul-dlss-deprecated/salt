source 'http://rubygems.org'

gem 'rake', '0.8.7'
gem 'rails', '3.2.19'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'blacklight'
gem 'blacklight-sitemap'
gem 'devise'
gem 'directory_watcher'
gem 'eventmachine'
gem 'rest-client'
gem 'simple-daemon'
gem "will_paginate",  '~> 3.0.2'
gem 'json'
gem 'active-fedora'
gem 'rubydora'
gem 'rails_config'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
group :production do
   gem "mysql2", '~> 0.2.13'
end


group :development, :test do
  gem 'rcov', :platform => :ruby_18
  gem 'sqlite3'
 # gem 'ruby-debug'
 # gem 'ruby-debug-base'
  gem 'rspec', '=2.6.0'
  gem 'rspec-rails'
  gem 'email_spec'
  gem 'mocha'
  gem 'cucumber', '>=0.8.5'
  gem 'cucumber-rails', '>0.4.0'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'gherkin'
  gem 'factory_girl'
	gem 'fakeweb'
	gem 'jettywrapper', "~> 1.3"
	gem 'equivalent-xml'
end
