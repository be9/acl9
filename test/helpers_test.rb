require 'test_helper'

require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9')

module SomeHelper
  include Acl9Helpers

  access_control :the_question do
    allow :hamlet, :to => :be
    allow :hamlet, :except => :be
  end
end

class HelperTest < Test::Unit::TestCase
  module Hamlet
    def current_user
      user = Object.new

      class <<user
        def has_role?(role, object=nil)
          if object
            return (role == 'hamlet' && object.name == 'castle')
          else
            return role == 'hamlet'
          end
        end
      end

      user
    end
  end

  module NotLoggedIn
    def current_user; nil end
  end

  module Noone
    def current_user
      user = Object.new

      class <<user
        def has_role?(*_); false end
      end

      user
    end
  end

  class Base
    include SomeHelper

    attr_accessor :action_name
    def controller
      self
    end
  end

  class Klass1 < Base
    include Hamlet
  end

  class Klass2 < Base
    include NotLoggedIn
  end

  class Klass3 < Base
    include Noone
  end

  it "has :the_question method" do
    Base.new.should respond_to(:the_question)
  end

  it "role :hamlet is allowed to be" do
    k = Klass1.new
    k.action_name = 'be'
    k.the_question.should be_true
  end

  it "role :hamlet is allowed to not_be" do
    k = Klass1.new
    k.action_name = 'not_be'
    k.the_question.should be_true
  end

  it "not logged in is not allowed to be" do
    k = Klass2.new
    k.action_name = 'be'
    k.the_question.should == false
  end

  it "noone is not allowed to be" do
    k = Klass3.new
    k.action_name = 'be'
    k.the_question.should == false
  end

  it "has :show_to method" do
    Base.new.should respond_to(:show_to)
  end

  it "has :show_to hamlet 'hello hamlet' message" do
    k = Klass1.new
    message = 'hello hamlet'
    k.show_to('hamlet') { message }.should == message
  end

  it "has to show message if user has hamlet role on object" do
    k = Klass1.new
    message = 'hello hamlet'

    obj = Object.new
    def obj.name; 'castle'; end

    k.show_to('hamlet', :of => obj) { message }.should == message
  end

  it "has not to show message if user has no hamlet role on object" do
    k = Klass1.new

    obj = Object.new
    def obj.name; 'persia'; end

    k.show_to('hamlet', :of => obj) { 'hello my prince' }.should == nil
  end

  it "has :show_to nothing to NotLoggedIn" do
    k = Klass2.new
    k.action_name = 'be'
    message = 'hello hamlet'
    k.show_to(:hamlet) { message }.should == nil
  end
end
