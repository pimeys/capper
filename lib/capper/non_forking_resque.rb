require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables
  _cset(:non_forking_resque_workers, {})

  # these cannot be overriden
  set(:non_forking_resque_script) { File.join(bin_path, "non_forking_resque") }

  monit_config "non_forking_resque", <<EOF, :roles => :worker
<% non_forking_resque_workers.each do |name, queue| %>
check process non_forking_resque_<%= name %>
  with pidfile <%= pid_path %>/non_forking_resque.<%= name %>.pid
<% if queue.nil? %>
  start program = "<%= non_forking_resque_script %> <%= name %> * start"
  stop program = "<%= non_forking_resque_script %> <%= name %> * stop"
<% else %>
  start program = "<%= non_forking_resque_script %> <%= name %> <%= queue %> start"
  stop program = "<%= non_forking_resque_script %> <%= name %> <%= queue %> stop"
<% end %>
  group non_forking_resque

<% end %>
EOF

  namespace :non_forking_resque do
    desc "Generate non_forking_resque configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("non_forking_resque.sh",
                           non_forking_resque_script,
                           :mode => "0755")
    end

    desc "Restart non_forking_resque workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit -g non_forking_resque restart all"
    end
  end

  after "deploy:update_code", "non_forking_resque:setup"
  after "deploy:restart", "non_forking_resque:restart"
end
