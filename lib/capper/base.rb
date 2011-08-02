require 'capistrano'

unless Capistrano::Configuration.respond_to?(:instance)
  abort "capper requires Capistrano 2"
end

# mixin various helpers
require 'capistrano_colors/configuration'
require 'capistrano_colors/logger'

require 'capper/utils/load'

require 'capper/utils/templates'
include Capper::Utils::Templates

require 'capper/utils/multistage'
include Capper::Utils::Multistage

# define a bunch of defaults that make sense
Capper.load do
  # do not trace by default
  logger.level = Capistrano::Logger::DEBUG

  # add custom color scheme
  colorize([
    { :match => /executing `.*/,             :color => :yellow,  :level => 2, :prio => -10, :attribute => :bright, :prepend => "== Currently " },
    { :match => /executing ".*/,             :color => :magenta, :level => 2, :prio => -20 },
    { :match => /sftp upload complete/,      :color => :hide,    :level => 2, :prio => -20 },

    { :match => /^transaction:.*/,           :color => :blue,    :level => 1, :prio => -10, :attribute => :bright },
    { :match => /.*out\] (fatal:|ERROR:).*/, :color => :red,     :level => 1, :prio => -10 },
    { :match => /Permission denied/,         :color => :red,     :level => 1, :prio => -20 },
    { :match => /sh: .+: command not found/, :color => :magenta, :level => 1, :prio => -30 },

    { :match => /^err ::/,                   :color => :red,     :level => 0, :prio => -10 },
    { :match => /.*/,                        :color => :blue,    :level => 0, :prio => -20, :attribute => :bright },
  ])

  # apps should not require root access
  set(:use_sudo, false)
  set(:group_writable, false)

  # default app layout
  _cset(:user) { application }
  _cset(:bin_path) { File.join(deploy_to, "bin") }
  _cset(:base_path) { "/var/app" }
  _cset(:config_path) { "#{shared_path}/config" }
  set(:deploy_to) { "#{base_path}/#{application}" }

  # cleanup by default
  after "deploy:update", "deploy:cleanup"

  namespace :deploy do
    desc <<-DESC
      Prepares one or more servers for deployment. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:

        $ cap HOSTS=new.server.com deploy:setup

      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
    task :setup, :except => { :no_release => true } do
      shared = %w(system log pids) | shared_children
      dirs = [releases_path, shared_path]
      dirs += shared.map { |d| File.join(shared_path, d) }
      run "mkdir -p #{dirs.join(' ')}"
    end
  end
end
