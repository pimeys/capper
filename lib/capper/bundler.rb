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

  # freeze bundler version
  _cset(:bundler_version, "1.0.17")

  namespace :bundle do
    desc "Setup bundler"
    task :setup, :except => {:no_release => true} do
      run "if ! gem query -i -n ^bundler$ -v #{bundler_version} >/dev/null; then " +
          "gem install bundler -v #{bundler_version}; " +
          "fi"
      run "mkdir -p #{bundle_dir}"
    end
  end

  before "bundle:install", "bundle:setup"
end
