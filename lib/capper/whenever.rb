require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# whenever requires bundler
require 'capper/bundler'

Capper.load do
  set(:whenever_command) { "bundle exec whenever" }
  set(:whenever_identifier) { application }
  set(:whenever_environment) { fetch(:rails_env, "production") }
  set(:whenever_update_flags) { "--update-crontab #{whenever_identifier} --set environment=#{whenever_environment}" }
  set(:whenever_clear_flags) { "--clear-crontab #{whenever_identifier}" }

  # Disable cron jobs at the begining of a deploy.
  after "deploy:update_code", "whenever:clear_crontab"
  # Write the new cron jobs near the end.
  after "deploy:symlink", "whenever:update_crontab"
  # If anything goes wrong, undo.
  after "deploy:rollback", "whenever:update_crontab"

  namespace :whenever do
    desc <<-DESC
      Update application's crontab entries using Whenever. You can configure \
      the command used to invoke Whenever by setting the :whenever_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec whenever". You can configure the identifier used by setting \
      the :whenever_identifier variable, which defaults to the same value configured \
      for the :application variable. You can configure the environment by setting \
      the :whenever_environment variable, which defaults to the same value \
      configured for the :rails_env variable which itself defaults to "production". \
      Finally, you can completely override all arguments to the Whenever command \
      by setting the :whenever_update_flags variable.
    DESC
    task :update_crontab do
      on_rollback do
        if previous_release
          run "cd #{previous_release} && #{whenever_command} #{whenever_update_flags}"
        else
          run "cd #{release_path} && #{whenever_command} #{whenever_clear_flags}"
        end
      end

      run "cd #{current_path} && #{whenever_command} #{whenever_update_flags}"
    end

    desc <<-DESC
      Clear application's crontab entries using Whenever. You can configure \
      the command used to invoke Whenever by setting the :whenever_command \
      variable, which can be used with Bundler to set the command to \
      "bundle exec whenever". You can configure the identifier used by setting \
      the :whenever_identifier variable, which defaults to the same value configured \
      for the :application variable. Finally, you can completely override all \
      arguments to the Whenever command by setting the :whenever_clear_flags variable.
    DESC
    task :clear_crontab do
      run "cd #{release_path} && #{whenever_command} #{whenever_clear_flags}"
    end
  end
end
