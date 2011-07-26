require 'capper' unless defined?(Capper)

Capper.load do
  _cset(:config_repo) { abort "Please specify the config repository, set :config_repo, 'foo'" }

  after "deploy:setup" do
    run "rm -rf #{config_path} && git clone #{config_repo} #{config_path}"
  end

  after "deploy:update_code" do
    run "cd #{config_path} && git pull"
  end
end
