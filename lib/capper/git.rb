require File.dirname(__FILE__) + '/base' unless defined?(Capper)

Capper.load do
  set(:scm, :git)
  set(:deploy_via, :remote_cache)
end
