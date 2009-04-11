require 'rubygems'
require 'test/unit'
require 'context'
require 'matchy'
require 'active_support'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :dbfile => 'test.sqlite3')

class Test::Unit::TestCase
  custom_matcher :be_false do |receiver, matcher, args|
    !receiver
  end
  
  custom_matcher :be_true do |receiver, matcher, args|
    !!receiver
  end
end
