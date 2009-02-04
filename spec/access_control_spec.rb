require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9')
require File.join(File.dirname(__FILE__), 'controllers')

describe "permit anonymous to index and show and admin everywhere else", :shared => true do
  class Admin
    def has_role?(role, obj = nil)
      role == "admin"
    end
  end

  [:index, :show].each do |act|
    it "should permit anonymous to #{act}" do
      get act 
      response.body.should == 'OK'
    end
  end

  [:new, :edit, :update, :delete, :destroy].each do |act|
    it "should forbid anonymous to #{act}" do
      get act 
      response.body.should == 'AccessDenied'
    end
  end
  
  [:index, :show, :new, :edit, :update, :delete, :destroy].each do |act|
    it "should permit admin to #{act}" do
      get act, :user => Admin.new
      response.body.should == 'OK'
    end
  end
end

describe ACLBlock, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe ACLMethod, :type => :controller do
  it "should add :acl as a method" do
    controller.should respond_to(:acl)
  end

  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe ACLMethod2, :type => :controller do
  it "should add :acl as a method" do
    controller.should respond_to(:acl)
  end

  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe ACLArguments, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe ACLBooleanMethod, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe ACLIvars, :type => :controller do
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

  it "should allow owner of foo to destroy" do
    delete :destroy, :user => OwnerOfFoo.new
    response.body.should == 'OK'
  end
  
  it "should allow bartender to destroy" do
    delete :destroy, :user => Bartender.new
    response.body.should == 'OK'
  end
end

describe ACLSubjectMethod, :type => :controller do
  class TheOnlyUser 
    include Singleton

    def has_role?(role, subj)
      role == "the_only_one"
    end
  end

  it "should allow the only user to index" do
    get :index, :user => TheOnlyUser.instance
    response.body.should == 'OK'
  end
  
  it "should deny anonymous to index" do
    get :index
    response.body.should == 'AccessDenied'
  end
end

class FooOwner
  def has_role?(role_name, obj)
    role_name == 'owner' && obj == MyDearFoo.instance
  end
end

describe ACLObjectsHash, :type => :controller do
  it "should consider objects hash and prefer it to @ivar" do
    get :allow, :user => FooOwner.new
    response.body.should == 'OK'
  end
  
  it "should return AccessDenied when not logged in" do
    get :allow
    response.body.should == 'AccessDenied'
  end
end

describe ACLHelperMethod, :type => :controller do
  it "should return OK checking helper method" do
    get :allow, :user => FooOwner.new
    response.body.should == 'OK'
  end
  
  it "should return AccessDenied when not logged in" do
    get :allow
    response.body.should == 'AccessDenied'
  end
end

describe "Argument checking" do
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
