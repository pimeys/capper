require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# Unicorn capistrano controls.
# See http://unicorn.bogomips.org/SIGNALS.html for signals that can be sent to unicorn.

# unicorn requires bundler
require 'capper/bundler'

Capper.load do
  # unicorn configuration variables
  _cset(:unicorn_worker_processes, 4)
  _cset(:unicorn_backlog, 64)

  # these cannot be overriden
  set(:unicorn_script) { "#{bin_path}/unicorn" }
  set(:unicorn_config) { "#{config_path}/unicorn.rb" }
  set(:unicorn_pidfile) { "#{shared_path}/pids/unicorn.pid" }

  monit_config "unicorn", <<EOF
check process unicorn
  with pidfile "<%= shared_path %>/pids/unicorn.pid"
  start program = "<%= bin_path %>/unicorn start" with timeout 60 seconds
  stop program = "<%= bin_path %>/unicorn stop"
EOF

  namespace :deploy do
    desc "Start unicorn"
    task :start, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} start"
    end

    desc "Stop unicorn"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} stop"
    end

    desc "Restart unicorn with zero downtime"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} upgrade"
    end
  end

  namespace :unicorn do
    desc "Generate unicorn configuration files"
    task :setup, :roles => :app, :except => { :no_release => true } do
      upload_template_file("unicorn.rb", unicorn_config,
                           :mode => "0644", :prefix => "unicorn")
      upload_template_file("unicorn.sh", unicorn_script,
                           :mode => "0755", :prefix => "unicorn")
    end

    desc "Kill unicorn (this should only be used if all else fails)"
    task :kill, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} kill"
    end

    desc "Add a new worker to the currently running process"
    task :addworker, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} addworker"
    end

    desc "Remove a worker from the currently running process"
    task :delworker, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} delworker"
    end

    desc "Rotate all logfiles in the currently running process"
    task :logrotate, :roles => :app, :except => { :no_release => true } do
      run "#{unicorn_script} logrotate"
    end
  end

  after "deploy:update_code", "unicorn:setup"
end
