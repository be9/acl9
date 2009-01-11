require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9')

class EmptyController < ActionController::Base
  attr_accessor :current_user
  before_filter :set_current_user

  [:index, :show, :new, :edit, :update, :delete, :destroy].each do |act|
    define_method(act) {}
  end
  
  private

  def set_current_user
    if params[:user]
      self.current_user = params[:user]
    end
  end
end

class Admin
  def has_role?(role, obj = nil)
    role == "admin"
  end
end

# all these controllers behave the same way

class ACLBlock < EmptyController
  access_control do
    allow all, :to => [:index, :show]
    allow :admin
  end
end

class ACLMethod < EmptyController
  access_control :as_method => :acl do
    allow all, :to => [:index, :show]
    allow :admin, :except => [:index, :show]
  end
end

class ACLMethod2 < EmptyController
  access_control :acl do
    allow all, :to => [:index, :show]
    allow :admin, :except => [:index, :show]
  end
end

class ACLArguments < EmptyController
  access_control :except => [:index, :show] do
    allow :admin
  end
end

class ACLBooleanMethod < EmptyController
  access_control :acl, :filter => false do
    allow all, :to => [:index, :show]
    allow :admin
  end

  before_filter :check_acl

  def check_acl
    if self.acl
      true
    else 
      raise Acl9::AccessDenied
    end
  end
end

describe "permit anonymous to index and show and admin everywhere else", :shared => true do
  [:index, :show].each do |act|
    it "should permit anonymous to #{act}" do
      get act 
    end
  end

  [:new, :edit, :update, :delete, :destroy].each do |act|
    it "should forbid anonymous to #{act}" do
      lambda do
        get act 
      end.should raise_error(Acl9::AccessDenied)
    end
  end
  
  [:index, :show, :new, :edit, :update, :delete, :destroy].each do |act|
    it "should permit admin to #{act}" do
      get act, :user => Admin.new
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

class MyDearFoo
  include Singleton
end

class VenerableBar; end

class ACLIvars < EmptyController
  before_filter :set_ivars

  access_control do
    action :destroy do
      allow :owner, :of => :foo
      allow :bartender, :at => VenerableBar
    end
  end

  private

  def set_ivars
    @foo = MyDearFoo.instance
  end
end

describe ACLIvars, :type => :controller do
  class OwnerOfFoo
    def has_role?(role, obj)
      role == 'owner' && obj == MyDearFoo.instance
    end
  end
  
  class Bartender
    def has_role?(role, obj)
      role == 'bartender' && obj == VenerableBar
    end
  end

  it "should allow owner of foo to destroy" do
    delete :destroy, :user => OwnerOfFoo.new
  end
  
  it "should allow bartender to destroy" do
    delete :destroy, :user => Bartender.new
  end
end

class TheOnlyUser 
  include Singleton

  def has_role?(role, subj)
    role == "the_only_one"
  end
end

class ACLSubjectMethod < ActionController::Base
  access_control :subject_method => :the_only_user do
    allow :the_only_one
  end

  def index; end

  private

  def the_only_user
    params[:user]
  end
end

describe ACLSubjectMethod, :type => :controller do
  it "should allow the only user to index" do
    get :index, :user => TheOnlyUser.instance
  end
  
  it "should deny anonymous to index" do
    lambda do
      get :index
    end.should raise_error(Acl9::AccessDenied)
  end
end

class ACLObjectsHash < ActionController::Base
  access_control :allowed?, :filter => false do
    allow :owner, :of => :foo
  end

  def allow
    @foo = nil
    raise unless allowed?(:foo => MyDearFoo.instance)
  end
  
  def current_user
    params[:user]
  end
end

describe ACLObjectsHash, :type => :controller do
  class FooOwner
    def has_role?(role_name, obj)
      role_name == 'owner' && obj == MyDearFoo.instance
    end
  end

  it "should consider objects hash and prefer it to @ivar" do
    get :allow, :user => FooOwner.new
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
      class FailureController < ActionController::Base
        access_control 
      end
    end
  end
  
  it "should raise ArgumentError with 1st argument which is not a symbol" do
    arg_err do
      class FailureController < ActionController::Base
        access_control 123 do end
      end
    end
  end
  
  it "should raise ArgumentError with more than 1 positional argument" do
    arg_err do
      class FailureController < ActionController::Base
        access_control :foo, :bar do end
      end
    end
  end
end
