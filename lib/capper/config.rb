require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  _cset(:config_repo, nil)

  after "deploy:setup" do
    unless config_repo.nil?
      run "rm -rf #{config_path} && git clone -q #{config_repo} #{config_path}"
    end
  end

  namespace :config do
    desc "Setup configuration files from config repo"
    task :setup, :roles => :app, :except => { :no_release => true } do
      unless config_repo.nil?
        run "cd #{config_path} && git pull -q"
      end

      fetch(:config_files, []).each do |f|
        run "cp #{config_path}/#{f} #{release_path}/config/"
      end
    end
  end

  after "deploy:update_code", "config:setup"
end
