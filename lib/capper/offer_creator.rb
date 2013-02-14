require File.dirname(__FILE__) + '/base' unless defined?(Capper)

require 'capper/bundler'
require 'capper/monit'

Capper.load do
  # configuration variables

  # these cannot be overriden
  set(:offer_creator_script) { File.join(bin_path, "offer_creator") }

  monit_config "offer_creator", <<EOF, :roles => :worker
check process offer_creator
  with pidfile <%= pid_path %>/offer_creator.pid
  start program = "<%= offer_creator_script %> start"
  stop program = "<%= offer_creator_script %> stop"
  group offer_creator
EOF

  namespace :offer_creator do
    desc "Generate offer_creator worker configuration files"
    task :setup, :except => { :no_release => true } do
      upload_template_file("offer_creator.sh",
                           offer_creator_script,
                           :mode => "0755")
    end

    desc "Restart offer_creator workers"
    task :restart, :roles => :worker, :except => { :no_release => true } do
      run "monit -g offer_creator restart all"
    end
  end

  after "deploy:update_code", "offer_creator:setup"
  after "deploy:restart", "offer_creator:restart"
end
