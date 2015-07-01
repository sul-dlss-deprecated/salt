source 'https://rubygems.org'

gem 'rake'
gem 'rails', '3.2.22'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'blacklight', '3.1.2'
gem 'blacklight-sitemap'
gem 'devise', "~> 2.0"
gem 'rest-client'
gem 'simple-daemon'
gem "will_paginate",  '~> 3.0.5'
gem 'json'
gem 'active-fedora', '4.5.2'
gem 'rubydora'
gem 'rails_config'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

group :production do
   gem "mysql2", '~> 0.3'
end

group :development, :test do
  gem 'sqlite3'
  gem 'jettywrapper', "~> 1.3"
  gem 'byebug'
end

group :development do
  
end

group :test do
  gem 'rspec', '~> 3.3'
  gem 'rspec-rails'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'factory_girl'
  gem 'test-unit'
end

group :deployment do
  gem 'capistrano', '~> 3.0'
  gem 'lyberteam-capistrano-devel'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
end

gem 'squash_ruby', require: 'squash/ruby'
gem 'squash_rails', require: 'squash/rails'
