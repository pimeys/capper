require 'capistrano'

unless Capistrano::Configuration.respond_to?(:instance)
  abort "capper requires Capistrano 2"
end

# mixin various helpers
require 'capper/utils/load'

require 'capper/utils/templates'
include Capper::Utils::Templates

require 'capper/utils/multistage'
include Capper::Utils::Multistage

# define a bunch of defaults that make sense
Capper.load do
  # apps should not require root access
  set(:use_sudo, false)
  set(:group_writable, false)

  # default app layout
  _cset(:user) { application }
  _cset(:bin_path) { File.join(deploy_to, "bin") }
  _cset(:base_path) { "/var/app" }
  set(:deploy_to) { "#{base_path}/#{application}" }

  # cleanup by default
  after "deploy:update", "deploy:cleanup"
end
