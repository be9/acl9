require 'rubygems'

gem 'jnunemaker-matchy', '>= 0.4.0'
gem 'be9-context', '>= 0.5.5'

require 'test/unit'
require 'context'
require 'matchy'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'test.sqlite3')

class Test::Unit::TestCase
  custom_matcher :be_false do |receiver, matcher, args|
    !receiver
  end

  custom_matcher :be_true do |receiver, matcher, args|
    !!receiver
  end
end

ActionController::Routing::Routes.draw do |map|
  map.connect ":controller/:action/:id"
end

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActionController::Base.logger = ActiveRecord::Base.logger
