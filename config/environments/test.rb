Salt::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end

FEDORA_URI = "http://127.0.0.1:8983/fedora"
FEDORA_USER = "fedoraAdmin"
FEDORA_PASSWORD = "fedoraAdmin"

ASSET_SERVER_URI = "http://stanford.edu/~cfitz"
ASSET_SERVER_USER = "fedoraAdmin"
ASSET_SERVER_PASSWORD = "fedoraAdmin"

FLIPBOOK_URL = "http://salt-dev.stanford.edu:8080/flipbook_salt/"
FLIPBOOK_IP = "171.67.34.68"
DJATOKA_IP = "171.67.34.129"

# These are used to configure the Zotero Ingest Directory watcher.

DIRECTORY_WATCHER_DIR = File.join(Dir.tmpdir,  Time.now.strftime("%s"))
FileUtils.mkdir(DIRECTORY_WATCHER_DIR) #for testing, we need to make a new directory in the systems's temp direct @ startup.
DIRECTORY_WATCHER_INTERVAL = 1
DIRECTORY_WATCHER_STABLE = 1