require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  task "gem:setup" do
    put("gem: --no-ri --no-rdoc", "#{deploy_to}/.gemrc")
  end
end
