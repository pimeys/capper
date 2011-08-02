require File.dirname(__FILE__) + '/base' unless defined?(Capper)

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'

require "capper/gem"

Capper.load do
  set(:rvm_type, :user)
  set(:rvm_ruby_string, File.read(".rvmrc").gsub(/^rvm use --create (.*)/, '\1').strip)

  namespace :rvm do
    # install the requested ruby if missing
    desc "Install the selected ruby version using RVM."
    task :setup, :except => {:no_release => true} do
      wo_gemset = rvm_ruby_string.gsub(/@.*/, '')
      run("if ! rvm list rubies | grep -q #{wo_gemset}; then " +
          "rvm install #{rvm_ruby_string}; fi && " +
          "rvm use --create #{rvm_ruby_string}",
          :shell => "/bin/bash -l")

      # this ensures that Gentoos declare -x RUBYOPT="-rauto_gem" is ignored.
      run "touch ~/.rvm/rubies/#{wo_gemset}/lib/ruby/site_ruby/auto_gem.rb"
    end

    # prevents interactive rvm dialog
    task :trust_rvmrc, :except => {:no_release => true} do
      run "rvm rvmrc trust #{release_path} >/dev/null"
      run "rvm rvmrc trust #{current_path} >/dev/null"
    end
  end

  before "rvm:setup", "gem:setup"
  before "deploy:setup", "rvm:setup"
  after "deploy:symlink", "rvm:trust_rvmrc"
end
