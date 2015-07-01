# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'salt'
set :repo_url, 'git@github.com:sul-dlss/salt.git'

set :ssh_options, {
  keys: [Capistrano::OneTimeKey.temporary_ssh_private_key_path],
  forward_agent: true,
  auth_methods: %w(publickey password)
}


# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/lyberadmin/salt/'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/solr.yml config/fedora.yml config/initializers/squash.rb public/.htaccess}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin config/settings log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system zotero_ingests}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :bundle_audit_ignore, %w{CVE-2015-3226}

before 'deploy:compile_assets', 'squash:write_revision'

set :passenger_restart_with_touch, true

namespace :salt do
  task :watcher do
    within release_path do
      run "cd script/background; bundle exec ruby zotero_directory_watcher.rb stop; bundle exec ruby zotero_directory_watcher.rb start"
    end
  end
end
