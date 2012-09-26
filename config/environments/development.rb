Salt::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
   config.action_mailer.perform_deliveries = true
   config.action_mailer.delivery_method = :sendmail #:smtp

   config.action_mailer.raise_delivery_errors = false
   config.action_mailer.default_url_options = { :host => 'salt-app-dev.stanford.edu' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
end

# FEDORA_URI = "http://salt-dev.stanford.edu/fedora"
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
DIRECTORY_WATCHER_DIR="/tmp/test"
DIRECTORY_WATCHER_INTERVAL = 1
DIRECTORY_WATCHER_STABLE = 1
