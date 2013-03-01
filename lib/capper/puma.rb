require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# Puma capistrano controls.
# https://github.com/puma/puma

require 'capper/bundler'
require 'socket'

Capper.load do
  hostname = Socket.gethostname.split('.', 2).first
  # puma configuration variables
  _cset(:pumas, {})

  puma_min_threads = pumas[hostname.to_sym] ? pumas[hostname.to_sym][:min_threads] : 8
  puma_min_threads = pumas[hostname.to_sym] ? pumas[hostname.to_sym][:max_threads] : 32
  puma_min_threads = pumas[hostname.to_sym] ? pumas[hostname.to_sym][:workers] : 24

  # these cannot be overriden
  set(:puma_config) { File.join(deploy_to, "/current/script/puma_config.rb") }

  config_script = <<-EOF
check process puma
  with pidfile <%= pid_path %>/puma.pid
  start program = "<%= puma_script %> puma <%= workers %> <%= min_threads %> <%= max_threads %> start"
  stop program = "<%= puma_script %> puma <%= workers %> <%= min_threads %> <%= max_threads %> stop"
  group pumas
EOF

  monit_config "puma", config_script, :roles => :web

  namespace :puma do
    desc "Generate puma configuration files"
    task :setup, :roles => :app, :except => { :no_release => true } do
      puma_script = File.join(bin_path, "puma")
      upload_template_file("puma.sh",
                           puma_script,
                           :mode => "0755")
    end

    desc "Start puma"
    task :start, :roles => :app, :except => { :no_release => true } do
      run "#{deploy_to}/bin/puma puma #{workers} #{min_threads} #{max_threads} start"
    end

    desc "Stop puma"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run "#{deploy_to}/bin/puma puma #{workers} #{min_threads} #{max_threads} stop"
    end

    desc "Restart puma with zero downtime"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "#{deploy_to}/bin/puma puma #{workers} #{min_threads} #{max_threads} restart"
    end

    desc "Kill puma (this should only be used if all else fails)"
    task :kill, :roles => :app, :except => { :no_release => true } do
      run "#{deploy_to}/bin/puma puma #{workers} #{min_threads} #{max_threads} stop"
    end
  end

  after "deploy:update_code", "puma:setup"
  after "deploy:restart", "puma:restart"
end
