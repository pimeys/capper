require File.dirname(__FILE__) + '/../capper' unless defined?(Capper)

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'

Capper.load do
  set(:rvm_type, :user)
  set(:rvm_ruby_string, File.read(".rvmrc").gsub(/^rvm use --create (.*)/, '\1').strip)

  namespace :rvm do
    # install the requested ruby if missing
    desc "Install the selected ruby version using RVM."
    task :setup, :except => {:no_release => true} do
      wo_gemset = rvm_ruby_string.gsub(/@.*/, '')
      run("if ! rvm list rubies | grep -q #{wo_gemset}; then " +
          "rvm install #{rvm_ruby_string}; fi",
          :shell => "/bin/bash -l")

      # this ensures that Gentoos declare -x RUBYOPT="-rauto_gem" is ignored.
      run "touch ~/.rvm/rubies/#{rvm_ruby_string}/lib/ruby/site_ruby/auto_gem.rb"
    end

    # prevents interactive rvm dialog
    task :trust_rvmrc, :except => {:no_release => true} do
      run "rvm rvmrc trust #{current_path}"
    end
  end

  before "deploy:setup", "rvm:setup"
  after "deploy:update_code", "rvm:trust_rvmrc"
end
