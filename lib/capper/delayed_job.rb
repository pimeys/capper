require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'

Capper.load do
  # unicorn configuration variables
  _cset(:delayed_job_workers, {})

  # these cannot be overriden
  set(:delayed_job_script) { File.join(bin_path, "delayed_job") }

  monit_config "delayed_job", <<EOF, :roles => :worker
<% delayed_job_workers.each do |name, range| %>
check process delayed_job_<%= name %>
  with pidfile <%= pid_path %>/delayed_job.<%= name %>.pid
<% if range.nil? %>
  start program = "<%= delayed_job_script %> start <%= name %>"
  stop program = "<%= delayed_job_script %> stop <%= name %>"
<% else %>
  start program = "<%= delayed_job_script %> start <%= name %> <%= range.begin %> <%= range.end %>"
  stop program = "<%= delayed_job_script %> stop <%= name %> <%= range.begin %> <%= range.end %>"
<% end %>
  group delayed_job

<% end %>
EOF

  namespace :delayed_job do
    desc "Generate delayed_job configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("delayed_job.sh",
                           delayed_job_script,
                           :mode => "0755")
    end
  end

  after "deploy:update_code", "delayed_job:setup"
end
