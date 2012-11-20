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
  config/database.yml
  config/solr.yml
  config/fedora.yml
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

namespace :deploy do
  namespace :assets do
    task :symlink do ; end
    task :precompile do ; end
  end
end

