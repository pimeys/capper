require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables
  _cset(:interval, 1)
  _cset(:log_file, "#{deploy_to}/current/log/lhr.log")

  set(:lhr_script) { File.join(bin_path, "lhr") }

  monit_config "lhr", <<EOF, :roles => :worker
check process lhr
  with pidfile <%= pid_path %>/lhr.pid
  start program = "<%= lhr_script %> <%= debug %> <%= interval %> <%= log_file %> start"
  stop program = "<%= lhr_script %> <%= debug %> <%= interval %> <%= log_file %> stop" with timeout 180 seconds
  if totalmem > 3200 MB then restart
EOF

  namespace :lhr do
    desc "Generate lhr worker configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("lhr.sh",
                           lhr_script,
                           :mode => "0755")
    end

    desc "Restart lhr workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit restart lhr"
    end
  end

  after "deploy:update_code", "lhr:setup"
  after "deploy:restart", "lhr:restart"
end
