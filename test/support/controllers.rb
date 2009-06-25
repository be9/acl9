class ApplicationController < ActionController::Base
  rescue_from Acl9::AccessDenied do |e|
    render :text => 'AccessDenied'
  end
end

class EmptyController < ApplicationController
  attr_accessor :current_user
  before_filter :set_current_user

  [:index, :show, :new, :edit, :update, :delete, :destroy].each do |act|
    define_method(act) { render :text => 'OK' }
  end

  private

  def set_current_user
    if params[:user]
      self.current_user = params[:user]
    end
  end
end

module TrueFalse
  private

  def true_meth; true end
  def false_meth; false end
end

# all these controllers behave the same way

class ACLBlock < EmptyController
  access_control :debug => true do
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
    allow :admin, :if => :true_meth, :unless => :false_meth
  end

  include TrueFalse
end

class ACLBooleanMethod < EmptyController
  access_control :acl, :filter => false do
    allow all, :to => [:index, :show], :if => :true_meth
    allow :admin,                      :unless => :false_meth
    allow all,                         :if => :false_meth
    allow all,                         :unless => :true_meth
  end

  before_filter :check_acl

  def check_acl
    if self.acl
      true
    else 
      raise Acl9::AccessDenied
    end
  end

  include TrueFalse
end

###########################################
class MyDearFoo
  include Singleton 
end

class ACLIvars < EmptyController
  class VenerableBar; end

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

class ACLSubjectMethod < ApplicationController
  access_control :subject_method => :the_only_user do
    allow :the_only_one
  end

  def index
    render :text => 'OK'
  end

  private

  def the_only_user
    params[:user]
  end
end

class ACLObjectsHash < ApplicationController
  access_control :allowed?, :filter => false do
    allow :owner, :of => :foo
  end

  def allow
    @foo = nil
    render :text => (allowed?(:foo => MyDearFoo.instance) ? 'OK' : 'AccessDenied')
  end

  def current_user
    params[:user]
  end
end

class ACLActionOverride < ApplicationController
  access_control :allowed?, :filter => false do
    allow all, :to => :index
    deny all, :to => :show
    allow :owner, :of => :foo, :to => :edit
  end

  def check_allow
    render :text => (allowed?(params[:_action]) ? 'OK' : 'AccessDenied')
  end

  def check_allow_with_foo
    render :text => (allowed?(params[:_action], :foo => MyDearFoo.instance) ? 'OK' : 'AccessDenied')
  end

  def current_user
    params[:user]
  end
end


class ACLHelperMethod < ApplicationController
  access_control :helper => :foo? do
    allow :owner, :of => :foo
  end

  def allow
    @foo = MyDearFoo.instance

    render :inline => "<%= foo? ? 'OK' : 'AccessDenied' %>"
  end

  def current_user
    params[:user]
  end
end

class ACLQueryMethod < ApplicationController
  attr_accessor :current_user

  access_control :acl, :query_method => true do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end

class ACLQueryMethodWithLambda < ApplicationController
  attr_accessor :current_user

  access_control :query_method => :acl? do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end

class ACLNamedQueryMethod < ApplicationController
  attr_accessor :current_user

  access_control :acl, :query_method => 'allow_ay' do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end

  def acl?(*args)
    allow_ay(*args)
  end
end
