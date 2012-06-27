require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables
  _cset(:beanstalkd_workers, {})

  # these cannot be overriden
  set(:beanstalkd_script) { File.join(bin_path, "beanstalkd") }

  monit_config "beanstalkd", <<EOF, :roles => :worker
<% beanstalkd_workers.each do |name, opts| %>
check process payouts_and_callbacks_<%= name %>
  with pidfile <%= pid_path %>/payouts_and_callbacks.<%= name %>.pid
<% if opts[:tubes].nil? %>
  start program = "<%= beanstalkd_script %> <%= name %> default <%= opts[:threads] || 1 %> start"
  stop program = "<%= beanstalkd_script %> <%= name %> default <%= opts[:threads] || 1 %> stop" with timeout 180 seconds
<% else %>
  start program = "<%= beanstalkd_script %> <%= name %> <%= opts[:tubes].join(':') %> <%= opts[:threads] || 1 %> start"
  stop program = "<%= beanstalkd_script %> <%= name %> <%= opts[:tubes].join(':') %> <%= opts[:threads] || 1 %> stop" with timeout 180 seconds
<% end %>
  group payouts_and_callbacks

<% end %>
EOF

  namespace :beanstalkd do
    desc "Generate beanstalkd worker configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("beanstalkd.sh",
                           beanstalkd_script,
                           :mode => "0755")
    end

    desc "Restart beanstalkd workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit -g payouts_and_callbacks restart all"
    end
  end

  after "deploy:update_code", "beanstalkd:setup"
  after "deploy:restart", "beanstalkd:restart"
end
