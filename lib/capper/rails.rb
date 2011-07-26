require File.dirname(__FILE__) + '/base' unless defined?(Capper)

# rails uses rvm and bundler
require 'capper/rvm'
require 'capper/bundler'

Capper.load do
  _cset(:rails_env, "production")
end
