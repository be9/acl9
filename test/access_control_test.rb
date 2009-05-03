require 'test_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9')
require 'support/controllers'

#######################################################################

class Admin
  def has_role?(role, obj = nil)
    role == "admin"
  end
end

class OwnerOfFoo
  def has_role?(role, obj)
    role == 'owner' && obj == MyDearFoo.instance
  end
end

class Bartender
  def has_role?(role, obj)
    role == 'bartender' && obj == ACLIvars::VenerableBar
  end
end

class TheOnlyUser 
  include Singleton

  def has_role?(role, subj)
    role == "the_only_one"
  end
end

#######################################################################

module BaseTests
  # permit anonymous to index and show and admin everywhere else
  def self.included(klass)
    klass.class_eval do
      [:index, :show].each do |act|
        it "should permit anonymous to #{act}" do
          get act 
          @response.body.should == 'OK'
        end
      end

      [:new, :edit, :update, :delete, :destroy].each do |act|
        it "should forbid anonymous to #{act}" do
          get act 
          @response.body.should == 'AccessDenied'
        end
      end
      
      [:index, :show, :new, :edit, :update, :delete, :destroy].each do |act|
        it "should permit admin to #{act}" do
          get act, :user => Admin.new
          @response.body.should == 'OK'
        end
      end
    end
  end
end

module ShouldRespondToAcl
  def self.included(klass)
    klass.class_eval do
      it "should add :acl as a method" do
        @controller.should respond_to(:acl)
      end
    end
  end
end

#######################################################################

class ACLBlockTest < ActionController::TestCase
  tests ACLBlock

  include BaseTests
end

class ACLMethodTest < ActionController::TestCase
  tests ACLMethod

  include BaseTests
  include ShouldRespondToAcl
end

class ACLMethod2Test < ActionController::TestCase
  tests ACLMethod2

  include BaseTests
  include ShouldRespondToAcl
end

class ACLArgumentsTest < ActionController::TestCase
  tests ACLArguments

  include BaseTests
end

class ACLBooleanMethodTest < ActionController::TestCase
  tests ACLBooleanMethod

  include BaseTests
end

class ACLIvarsTest < ActionController::TestCase
  tests ACLIvars
  
  it "should allow owner of foo to destroy" do
    delete :destroy, :user => OwnerOfFoo.new
    @response.body.should == 'OK'
  end
  
  it "should allow bartender to destroy" do
    delete :destroy, :user => Bartender.new
    @response.body.should == 'OK'
  end
end

class ACLSubjectMethodTest < ActionController::TestCase
  tests ACLSubjectMethod

  it "should allow the only user to index" do
    get :index, :user => TheOnlyUser.instance
    @response.body.should == 'OK'
  end
  
  it "should deny anonymous to index" do
    get :index
    @response.body.should == 'AccessDenied'
  end
end

class ACLObjectsHashTest < ActionController::TestCase
  tests ACLObjectsHash

  it "should consider objects hash and prefer it to @ivar" do
    get :allow, :user => OwnerOfFoo.new
    @response.body.should == 'OK'
  end
  
  it "should return AccessDenied when not logged in" do
    get :allow
    @response.body.should == 'AccessDenied'
  end
end

class ACLHelperMethodTest < ActionController::TestCase
  tests ACLHelperMethod

  it "should return OK checking helper method" do
    get :allow, :user => OwnerOfFoo.new
    @response.body.should == 'OK'
  end
  
  it "should return AccessDenied when not logged in" do
    get :allow
    @response.body.should == 'AccessDenied'
  end
end

class ArgumentsCheckingTest < ActiveSupport::TestCase
  def arg_err(&block)
    lambda do
      block.call
    end.should raise_error(ArgumentError)
  end
  
  it "should raise ArgumentError without a block" do
    arg_err do
      class FailureController < ApplicationController
        access_control 
      end
    end
  end
  
  it "should raise ArgumentError with 1st argument which is not a symbol" do
    arg_err do
      class FailureController < ApplicationController
        access_control 123 do end
      end
    end
  end
  
  it "should raise ArgumentError with more than 1 positional argument" do
    arg_err do
      class FailureController < ApplicationController
        access_control :foo, :bar do end
      end
    end
  end
  
  it "should raise ArgumentError with :helper => true and no method name" do
    arg_err do
      class FailureController < ApplicationController
        access_control :helper => true do end
      end
    end
  end
  
  it "should raise ArgumentError with :helper => :method and a method name" do
    arg_err do
      class FailureController < ApplicationController
        access_control :meth, :helper => :another_meth do end
      end
    end
  end
end
