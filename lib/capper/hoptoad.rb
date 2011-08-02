require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# hoptoad requires bundler
require 'capper/bundler'

Capper.load do
  # redefine the notify task without after hooks, so we can use them in
  # specific stages only.
  namespace :hoptoad do
    desc "Notify Hoptoad of the deployment"
    task :notify, :except => { :no_release => true } do
      rails_env = fetch(:hoptoad_env, fetch(:rails_env, "production"))
      local_user = ENV['USER'] || ENV['USERNAME']
      executable = fetch(:rake, 'rake')

      notify_command = "#{executable} hoptoad:deploy TO=#{rails_env} REVISION=#{current_revision} REPO=#{repository} USER=#{local_user}"
      notify_command << " DRY_RUN=true" if dry_run
      notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']

      puts "Notifying Hoptoad of Deploy (#{notify_command})"
      `#{notify_command}`
      puts "Hoptoad Notification Complete."
    end
  end
end
