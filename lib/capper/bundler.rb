require File.dirname(__FILE__) + '/../capper' unless defined?(Capper)
require 'bundler/capistrano'

Capper.load do
  namespace :bundle do
    desc "Setup bundler"
    task :setup, :except => {:no_release => true} do
      run "if ! gem query -i -n ^bundler$ >/dev/null; then gem install bundler; fi"
    end
  end

  before "bundle:install", "bundle:setup"
end
