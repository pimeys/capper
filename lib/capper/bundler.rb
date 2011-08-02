require File.dirname(__FILE__) + '/base' unless defined?(Capper)
require 'bundler/capistrano'

# bundler requires rvm
require "capper/rvm"

Capper.load do
  # always execute rake with bundler to make sure we use the right version
  set(:rake, "bundle exec rake")

  # do not install a global bundle
  # instead, use the gemset selected by rvm_ruby_string
  set(:bundle_dir) { File.join(shared_path, 'bundle', rvm_ruby_string) }

  namespace :bundle do
    desc "Setup bundler"
    task :setup, :except => {:no_release => true} do
      run "if ! gem query -i -n ^bundler$ >/dev/null; then gem install bundler; fi"
      run "mkdir -p #{bundle_dir}"
    end
  end

  before "bundle:install", "bundle:setup"
end
