require 'net/ssh/kerberos'
require 'bundler/setup'
require 'bundler/capistrano'
require 'dlss/capistrano'
require 'pathname'

set :stages, %W(dev prod)
set :default_stage, "dev"
set :bundle_flags, "--quiet"

require 'capistrano/ext/multistage'

#after "deploy:restart", "dlss:log_release"

set :shared_children, %w(
  log
  db
  config/database.yml
  config/solr.yml
  config/fedora.yml
  config/environments
  public/.htaccess
  zotero_ingests
)

set :user, "lyberadmin"
set :runner, "lyberadmin"
set :ssh_options, {
  :auth_methods  => %w(gssapi-with-mic publickey hostbased),
  :forward_agent => true
}

set :destination, "/home/lyberadmin"
set :application, "salt"

set :scm, :git
set :copy_cache, true
set :copy_exclude, [".git"]
set :use_sudo, false
set :keep_releases, 2

set :deploy_to, "#{destination}/#{application}"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy", "deploy:migrate"

after "deploy", "salt:watcher"

namespace :salt do
  task :watcher do
    run "cd #{deploy_to}/script/background; RAILS_ENV=#{rails_env} bundle exec ruby zotero_directory_watcher.rb stop; RAILS_ENV=#{rails_env} bundle exec ruby zotero_directory_watcher.rb start"
  end
end

namespace :deploy do
  namespace :assets do
    task :symlink do ; end
    task :precompile do ; end
  end
end

