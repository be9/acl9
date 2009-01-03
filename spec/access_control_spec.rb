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

class AccessControllingController1 < EmptyController
  access_control do
    allow all, :to => [:index, :show]
    allow :admin
  end
end

class AccessControllingController2 < EmptyController
  access_control :as_method => :acl do
    allow all, :to => [:index, :show]
    allow :admin, :except => [:index, :show]
  end
end

class AccessControllingController3 < EmptyController
  access_control :except => [:index, :show] do
    allow :admin
  end
end

class AccessControllingController4 < EmptyController
  access_control :as_method => :acl, :filter => false do
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

describe AccessControllingController1, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe AccessControllingController2, :type => :controller do
  it "should add :acl as a method" do
    controller.should respond_to(:acl)
  end

  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe AccessControllingController3, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

describe AccessControllingController4, :type => :controller do
  it_should_behave_like "permit anonymous to index and show and admin everywhere else"
end

class MyDearFoo
  include Singleton
end

class VenerableBar; end

class AccessControllingController5 < EmptyController
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

describe AccessControllingController5, :type => :controller do
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

class AccessControllingController6 < ActionController::Base
  access_control :subject_method => :the_only_user do
    allow :the_only_one
  end

  def index; end

  private

  def the_only_user
    params[:user]
  end
end

describe AccessControllingController6, :type => :controller do
  it "should allow the only user to index" do
    get :index, :user => TheOnlyUser.instance
  end
  
  it "should deny anonymous to index" do
    lambda do
      get :index
    end.should raise_error(Acl9::AccessDenied)
  end
end
