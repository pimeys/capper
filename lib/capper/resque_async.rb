require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables
  _cset(:resque_async_workers, {})

  # these cannot be overriden
  set(:resque_async_script) { File.join(bin_path, "resque_async") }

  monit_config "resque_async", <<EOF, :roles => :worker
<% resque_async_workers.each do |name, queue| %>
check process resque_async_<%= name %>
  with pidfile <%= pid_path %>/resque_async.<%= name %>.pid
<% if queue.nil? %>
  start program = "<%= resque_async_script %> <%= name %> * <%= fibers %> <%= interval %> start"
  stop program = "<%= resque_async_script %> <%= name %> * <%= fibers %> <%= interval %> stop"
<% else %>
  start program = "<%= resque_async_script %> <%= name %> <%= queue %> <%= fibers %> <%= interval %> start"
  stop program = "<%= resque_async_script %> <%= name %> <%= queue %> <%= fibers %> <%= interval %> stop"
<% end %>
  group resque_async

<% end %>
EOF

  namespace :resque_async do
    desc "Generate resque_async configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("resque_async.sh",
                           resque_async_script,
                           :mode => "0755")
    end

    desc "Restart async resque workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit -g resque_async restart all"
    end
  end

  after "deploy:update_code", "resque_async:setup"
  after "deploy:restart", "resque_async:restart"
end
