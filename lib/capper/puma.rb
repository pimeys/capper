require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# Puma capistrano controls.
# https://github.com/puma/puma

require 'capper/bundler'

Capper.load do
  # puma configuration variables
  _cset(:puma_min_threads, 1)
  _cset(:puma_max_threads, 4)
  _cset(:puma_worker_processes, 1)

  # these cannot be overriden
  set(:puma_config) { File.join(config_path, "puma.rb") }

  config_script = (1..puma_worker_processes).map do |i|
    <<-EOF
check process puma_<%= i %>
  with pidfile <%= pid_path %>/puma_<%= i %>.pid
  start program = "<%= puma_script %> puma_<%= i %> <%= puma_min_threads %> <%= max_threads %> start"
  stop program = "<%= puma_script %> puma_<%= i %> <%= puma_min_threads %> <%= max_threads %> stop"
  group pumas
    EOF
  end.join("\n")

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
      (1..puma_worker_processes).each do |i|
        run "monit start puma#{i}"
      end
    end

    desc "Stop puma"
    task :stop, :roles => :app, :except => { :no_release => true } do
      (1..puma_worker_processes).each do |i|
        puma_script = File.join(bin_path, "puma#{i}")
        run "monit stop puma#{i}"
      end
    end

    desc "Restart puma with zero downtime"
    task :restart, :roles => :app, :except => { :no_release => true } do
      (1..puma_worker_processes).each do |i|
        puma_script = File.join(bin_path, "puma#{i}")
        run "#{deploy_to}/bin/puma puma_#{i} #{puma_min_threads} #{puma_max_threads} restart"
      end
    end

    desc "Kill puma (this should only be used if all else fails)"
    task :kill, :roles => :app, :except => { :no_release => true } do
      (1..puma_worker_processes).each do |i|
        puma_script = File.join(bin_path, "puma#{i}")
        run "monit stop puma#{i}"
      end
    end
  end

  after "deploy:update_code", "puma:setup"
  after "deploy:restart", "puma:restart"
end
