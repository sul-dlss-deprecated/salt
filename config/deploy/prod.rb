set :rails_env, "production"
set :deployment_host, "salt-app.stanford.edu"
set :repository, "/afs/ir/dev/dlss/git/appteam/salt.git"
set :deploy_via, :remote_cache
DEFAULT_TAG='master'
set :bundle_without, [:deployment,:development,:test]

role :web, deployment_host
role :app, deployment_host
role :db,  deployment_host, :primary => true

