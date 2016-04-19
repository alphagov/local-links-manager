set :application, "local-links-manager"
set :capfile_dir, File.expand_path('../', File.dirname(__FILE__))
set :server_class, "backend"

load 'defaults'
load 'ruby'

after "deploy:notify", "deploy:notify:errbit"

