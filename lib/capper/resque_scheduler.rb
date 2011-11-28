require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables
  _cset(:resque_scheduler_workers, [])

  # these cannot be overriden
  set(:resque_scheduler_script) { File.join(bin_path, "resque_scheduler") }

  monit_config "resque_scheduler", <<EOF, :roles => :worker
<% resque_scheduler_workers.each do |name| %>
check process resque_scheduler_<%= name %>
  with pidfile <%= pid_path %>/resque_scheduler.<%= name %>.pid
  start program = "<%= resque_scheduler_script %> <%= name %> start"
  stop program = "<%= resque_scheduler_script %> <%= name %> stop"
  group resque_scheduler

<% end %>
EOF

  namespace :resque_scheduler do
    desc "Generate resque_scheduler configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("resque_scheduler.sh",
                           resque_scheduler_script,
                           :mode => "0755")
    end

    desc "Restart resque scheduler workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit -g resque_scheduler restart all"
    end
  end

  after "deploy:update_code", "resque_scheduler:setup"
  after "deploy:restart", "resque_scheduler:restart"
end
