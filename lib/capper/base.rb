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

require 'capper/utils/monit'
include Capper::Utils::Monit

# define a bunch of defaults that make sense
Capper.load do
  # do not trace by default
  logger.level = Capistrano::Logger::DEBUG

  # add custom color scheme
  colorize([
    { :match => /executing `.*/,             :color => :yellow,  :level => 2, :prio => -10, :attribute => :bright, :prepend => "== Currently " },
    { :match => /executing ".*/,             :color => :magenta, :level => 2, :prio => -20 },
    { :match => /sftp upload complete/,      :color => :hide,    :level => 2, :prio => -20 },

    { :match => /sftp upload/,               :color => :hide,    :level => 1, :prio => -10 },
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

  _cset(:base_path) { "/var/app" }
  set(:deploy_to) { "#{base_path}/#{application}" }

  _cset(:bin_path) { File.join(deploy_to, "bin") }
  _cset(:pid_path) { File.join(shared_path, "pids") }
  _cset(:config_path) { File.join(shared_path, "config") }

  # set proper unicode locale, so gemspecs with unicode chars will not crash
  # bundler. see https://github.com/capistrano/capistrano/issues/70
  _cset(:default_environment, { 'LANG' => 'en_US.UTF-8' })

  # overwrite deploy:setup to get rid of the annoying chmod g+w which makes ssh
  # logins impossible
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

    desc "Create symlinks from shared to current"
    task :symlink_shared, :roles => :app, :except => { :no_release => true } do
      fetch(:symlinks, {}).each do |source, dest|
        run "rm -rf #{release_path}/#{dest} && ln -nfs #{shared_path}/#{source} #{release_path}/#{dest}"
      end
    end
  end

  # cleanup by default
  after "deploy:update", "deploy:cleanup"
  after "deploy:update_code", "deploy:symlink_shared"
end
