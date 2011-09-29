require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# rails uses rvm and bundler
require 'capper/rvm'
require 'capper/bundler'

Capper.load do
  _cset(:rails_env, "production")

  namespace :rails do
    desc "Generate rails configuration and helpers"
    task :setup, :roles => :app, :except => { :no_release => true } do
      upload_template_file("rails.console.sh",
                           File.join(bin_path, "con"),
                           :mode => "0755")
    end
  end

  after "deploy:update_code", "rails:setup"
end
