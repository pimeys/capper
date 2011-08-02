require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  _cset(:config_repo, nil)

  after "deploy:setup" do
    unless config_repo.nil?
      run "rm -rf #{config_path} && git clone -q #{config_repo} #{config_path}"
    end
  end

  after "deploy:update_code" do
    unless config_repo.nil?
      run "cd #{config_path} && git pull -q"
    end

    fetch(:config_files, []).each do |f|
      run "cp #{config_path}/#{f} #{release_path}/config/"
    end

    fetch(:symlinks, {}).each do |source, dest|
      run "rm -rf #{release_path}/#{dest} && ln -nfs #{shared_path}/#{source} #{release_path}/#{dest}"
    end
  end
end
