require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  namespace :gemrc do
    desc "Setup global ~/.gemrc file"
    task :setup do
      put("gem: --no-ri --no-rdoc", "#{deploy_to}/.gemrc")
    end
  end
end
