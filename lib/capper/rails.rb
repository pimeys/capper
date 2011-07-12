require File.dirname(__FILE__) + '/../capper' unless defined?(Capper)

# rails uses rvm and bundler
require 'capper/rvm'
require 'capper/bundler'

Capper.load do
  _cset(:rails_env, "production")
end
