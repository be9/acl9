require 'ostruct'
require 'test_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9', 'controller_extensions', 'dsl_base')

class FakeUser
  def initialize
    @roles = {}
  end

  def has_role?(role, object = nil)
    @roles.include?([role.to_s, object])
  end

  def <<(role)
    role = [role] unless role.is_a? Array

    role << nil if role.size == 1
    raise unless role[0]

    role[0] = role[0].to_s

    @roles[role] = true
  end
end

class DslTester < Acl9::Dsl::Base
  def initialize
    super

    @_subject = nil
    @_objects = {}
    @_current_action = nil
  end

  def permit(user, *args)
    check_allowance(user, *args).should == true

    self
  end

  def forbid(user, *args)
    check_allowance(user, *args).should == false

    self
  end

  def show_code
    puts "\n", allowance_expression
    self
  end

  protected

  def check_allowance(subject, *args)
    @_subject = subject
    @_current_action = (args[0] || 'index').to_s
    @_objects = args.last.is_a?(Hash) ? args.last : {}
    @_callable = @_objects.delete(:call)

    instance_eval(allowance_expression)
  end

  def _subject_ref
    "@_subject"
  end

  def _object_ref(object)
    "@_objects[:#{object}]"
  end

  def _action_ref
    "@_current_action"
  end

  def _method_ref(method)
    "@_callable.send(:#{method})"
  end
end

#describe Acl9::Dsl::Base do
class DslBaseTest < Test::Unit::TestCase
  class ThatFoo; end
  class ThatBar; end

  def arg_err(&block)
    lambda do
      acl(&block)
    end.should raise_error(ArgumentError)
  end

  def acl(&block)
    tester = DslTester.new
    tester.acl_block!(&block)

    tester
  end

  def permit_some(tester, user, actions, vars = {})
    actions.each                  { |act| tester.permit(user, act, vars) }
    (@all_actions - actions).each { |act| tester.forbid(user, act, vars) }
  end

  before do
    @user = FakeUser.new
    @user2 = FakeUser.new
    @user3 = FakeUser.new
    @foo = ThatFoo.new
    @foo2 = ThatFoo.new
    @foo3 = ThatFoo.new
  end

  describe "default" do
    it "should set default action to deny if none specified" do
      acl do end.default_action.should == :deny
    end

    it "should set default action to allow" do
      acl do
        default :allow
      end.default_action.should == :allow
    end

    it "should set default action to deny" do
      acl do
        default :deny
      end.default_action.should == :deny
    end

    it "should raise ArgumentError with unknown default_action" do
      arg_err do
        default 123
      end
    end

    it "should raise ArgumentError when default is called more than once" do
      arg_err do
        default :deny
        default :deny
      end
    end
  end

  describe "empty blocks" do
    it "should deny everyone with default deny" do
      acl do
      end.forbid(nil).forbid(@user)
    end

    it "should allow everyone with default allow" do
      acl do
        default :allow
      end.permit(nil).permit(@user)
    end
  end

  describe "empty" do
    it "allow should raise an ArgumentError" do
      arg_err { allow }
    end

    it "deny should raise an ArgumentError" do
      arg_err { deny }
    end
  end

  describe "anonymous" do
    it "'allow nil' should allow anonymous, but not logged in" do
      acl do
        allow nil
      end.permit(nil).forbid(@user)
    end

    it "'allow anonymous' should allow anonymous, but not logged in" do
      acl do
        allow anonymous
      end.permit(nil).forbid(@user)
    end

    it "'deny nil' should deny anonymous, but not logged in" do
      acl do
        default :allow
        deny nil
      end.forbid(nil).permit(@user)
    end

    it "'deny anonymous' should deny anonymous, but not logged in" do
      acl do
        default :allow
        deny anonymous
      end.forbid(nil).permit(@user)
    end
  end

  describe "all" do
    [:all, :everyone, :everybody, :anyone].each do |pseudorole|
      it "'allow #{pseudorole}' should allow all" do
        acl do
          allow send(pseudorole)
        end.permit(nil).permit(@user)
      end

      it "'deny #{pseudorole}' should deny all" do
        acl do
          default :allow
          deny send(pseudorole)
        end.forbid(nil).forbid(@user)
      end
    end
  end

  describe "default :allow" do
    it "should allow when neither allow nor deny conditions are matched" do
      acl do
        default :allow
        allow :blah
        deny :bzz
      end.permit(nil).permit(@user)
    end

    it "should deny when deny is matched, but allow is not" do
      acl do
        default :allow
        deny all
        allow :blah
      end.forbid(nil).forbid(@user)
    end

    it "should allow when allow is matched, but deny is not" do
      @user << :cool
      acl do
        default :allow
        deny nil
        allow :cool
      end.permit(@user)
    end

    it "should allow both allow and deny conditions are matched" do
      @user << :cool
      acl do
        default :allow
        deny :cool
        allow :cool
      end.permit(@user)

      acl do
        default :allow
        deny all
        allow all
      end.permit(@user).permit(nil).permit(@user2)
    end
  end

  describe "logged_in" do
    it "'allow logged_in' should allow logged in, but not anonymous" do
      acl do
        allow logged_in
      end.forbid(nil).permit(@user)
    end

    it "'allow logged_in' should deny logged in, but not anonymous" do
      acl do
        default :allow
        deny logged_in
      end.permit(nil).forbid(@user)
    end
  end

  describe "default :deny" do
    it "should deny when neither allow nor deny conditions are matched" do
      acl do
        default :deny
        allow :blah
        deny :bzz
      end.forbid(nil).forbid(@user)
    end

    it "should deny when deny is matched, but allow is not" do
      acl do
        default :deny
        deny all
        allow :blah
      end.forbid(nil).forbid(@user)
    end

    it "should allow when allow is matched, but deny is not" do
      @user << :cool
      acl do
        default :deny
        deny nil
        allow :cool
      end.permit(@user)
    end

    it "should deny both allow and deny conditions are matched" do
      @user << :cool
      acl do
        default :deny
        deny :cool
        allow :cool
      end.forbid(@user)

      acl do
        default :deny
        deny all
        allow all
      end.forbid(@user).forbid(nil).forbid(@user2)
    end
  end

  describe "global roles" do
    it "#allow with role" do
      @user << :admin

      acl { allow :admin }.permit(@user).forbid(nil).forbid(@user2)
    end

    it "#allow with plural role name" do
      @user << :mouse

      acl do
        allow :mice
      end.permit(@user).forbid(nil).forbid(@user2)
    end

    it "#allow with several roles" do
      @user << :admin
      @user << :cool

      @user2 << :cool

      @user3 << :super

      acl do
        allow :admin
        allow :cool
      end.permit(@user).permit(@user2).forbid(nil).forbid(@user3)
    end

    it "#deny with role" do
      @user << :foo

      acl { default :allow; deny :foo }.forbid(@user).permit(nil).permit(@user2)
    end

    it "#deny with plural role name" do
      @user << :mouse

      acl do
        default :allow
        deny :mice
      end.forbid(@user).permit(nil).permit(@user2)
    end

    it "#deny with several roles" do
      @user << :admin
      @user << :cool

      @user2 << :cool

      @user3 << :super

      acl do
        default :allow
        deny :admin
        deny :cool
      end.forbid(@user).forbid(@user2).permit(nil).permit(@user3)
    end
  end

  describe "prepositions" do
    [:of, :for, :in, :on, :at, :by].each do |prep|
      it "#allow with object role (:#{prep}) should check controller's ivar" do
        @user << [:manager, @foo]

        acl do
          allow :manager, prep => :foo
        end.
        permit(@user, :foo => @foo).
        forbid(@user, :foo => @foo2).
        forbid(@user, :foo => ThatFoo).
        forbid(nil, :foo => @foo).
        forbid(@user2, :foo => @foo)
      end

      it "#allow with invalid value for preposition :#{prep} should raise an ArgumentError" do
        arg_err do
          allow :hom, :by => 1
        end
      end
    end

    it "#allow with a class role should verify this role against a class" do
      @user << [:owner, ThatFoo]

      acl do
        allow :owner, :of => ThatFoo
      end.permit(@user).forbid(nil).forbid(@user2)
    end

    [:of, :for, :in, :on, :at, :by].each do |prep|
      it "#deny with object role (:#{prep}) should check controller's ivar" do
        @user << [:bastard, @foo]

        acl do
          default :allow
          deny :bastard, prep => :foo
        end.
        forbid(@user, :foo => @foo).
        permit(@user, :foo => @foo2).
        permit(@user, :foo => ThatFoo).
        permit(nil, :foo => @foo).
        permit(@user2, :foo => @foo)
      end

      it "#deny with invalid value for preposition :#{prep} should raise an ArgumentError" do
        arg_err do
          deny :her, :for => "him"
        end
      end
    end

    it "#deny with a class role should verify this role against a class" do
      @user << [:ignorant, ThatFoo]

      acl do
        default :allow
        deny :ignorant, :of => ThatFoo
      end.forbid(@user).permit(nil).permit(@user2)
    end

    it "#allow with several prepositions should raise an ArgumentError" do
      arg_err do
        allow :some, :by => :one, :for => :another
      end
    end

    it "#deny with several prepositions should raise an ArgumentError" do
      arg_err do
        deny :some, :in => :here, :on => :today
      end
    end
  end

  describe ":to and :except" do
    it "should raise an ArgumentError when both :to and :except are specified" do
      arg_err do
        allow all, :to => :index, :except => ['show', 'edit']
      end
    end

    describe "" do
      after do
        %w(index show).each                 { |act| @list.permit(nil, act) }
        %w(edit update delete destroy).each { |act| @list.forbid(nil, act) }

        %w(index show edit update).each { |act| @list.permit(@user, act) }
        %w(delete destroy).each         { |act| @list.forbid(@user, act) }

        %w(index show edit update delete destroy).each { |act| @list.permit(@user2, act) }
      end

      it ":to should limit rule scope to specified actions" do
        @user << :manager
        @user2 << :trusted

        @list = acl do
          allow all,       :to => [:index, :show]

          allow 'manager', :to => :edit
          allow 'manager', :to => 'update'
          allow 'trusted', :to => %w(edit update delete destroy)
        end
      end

      it ":except should limit rule scope to all actions except specified" do
        @user << :manager
        @user2 << :trusted

        @list = acl do
          allow all,       :except => %w(edit update delete destroy)

          allow 'manager', :except => %w(delete destroy)
          allow 'trusted'
        end
      end
    end
  end

  describe "conditions" do
    [:if, :unless].each do |cond|
      it "should raise ArgumentError when #{cond} is not a Symbol" do
        arg_err do
          allow nil, cond => 123
        end
      end
    end

    it "allow ... :if" do
      acl do
        allow nil, :if => :meth
      end.
      permit(nil, :call => OpenStruct.new(:meth => true)).
      forbid(nil, :call => OpenStruct.new(:meth => false))
    end

    it "allow ... :unless" do
      acl do
        allow nil, :unless => :meth
      end.
      permit(nil, :call => OpenStruct.new(:meth => false)).
      forbid(nil, :call => OpenStruct.new(:meth => true))
    end

    it "deny ... :if" do
      acl do
        default :allow
        deny nil, :if => :meth
      end.
      permit(nil, :call => OpenStruct.new(:meth => false)).
      forbid(nil, :call => OpenStruct.new(:meth => true))
    end

    it "deny ... :unless" do
      acl do
        default :allow
        deny nil, :unless => :meth
      end.
      permit(nil, :call => OpenStruct.new(:meth => true)).
      forbid(nil, :call => OpenStruct.new(:meth => false))
    end

  end

  describe "several roles as arguments" do
    it "#allow should be able to receive a role list (global roles)" do
      @user << :bzz
      @user2 << :whoa

      acl do
        allow :bzz, :whoa
      end.permit(@user).permit(@user2).forbid(nil).forbid(@user3)
    end

    it "#allow should be able to receive a role list (object roles)" do
      @user << [:maker, @foo]
      @user2 << [:faker, @foo2]

      acl do
        allow :maker, :faker, :of => :foo
      end.
      permit(@user, :foo => @foo).
      forbid(@user, :foo => @foo2).
      permit(@user2, :foo => @foo2).
      forbid(@user2, :foo => @foo).
      forbid(@user3, :foo => @foo).
      forbid(@user3, :foo => @foo2).
      forbid(nil)
    end

    it "#allow should be able to receive a role list (class roles)" do
      @user  << [:frooble, ThatFoo]
      @user2 << [:oombigle, ThatFoo]
      @user3 << :frooble

      acl do
        allow :frooble, :oombigle, :by => ThatFoo
      end.
      permit(@user).
      permit(@user2).
      forbid(@user3).
      forbid(nil)
    end

    it "#deny should be able to receive a role list (global roles)" do
      @user << :bzz
      @user2 << :whoa

      acl do
        default :allow
        deny :bzz, :whoa
      end.forbid(@user).forbid(@user2).permit(nil).permit(@user3)
    end

    it "#deny should be able to receive a role list (object roles)" do
      @user << [:maker, @foo]
      @user2 << [:faker, @foo2]
      @user3 = FakeUser.new

      acl do
        default :allow
        deny :maker, :faker, :of => :foo
      end.
      forbid(@user, :foo => @foo).
      permit(@user, :foo => @foo2).
      forbid(@user2, :foo => @foo2).
      permit(@user2, :foo => @foo).
      permit(@user3, :foo => @foo).
      permit(@user3, :foo => @foo2).
      permit(nil)
    end

    it "#deny should be able to receive a role list (class roles)" do
      @user  << [:frooble, ThatFoo]
      @user2 << [:oombigle, ThatFoo]
      @user3 << :frooble

      acl do
        default :allow
        deny :frooble, :oombigle, :by => ThatFoo
      end.
      forbid(@user).
      forbid(@user2).
      permit(@user3).
      permit(nil)
    end

    it "should also respect :to and :except" do
      class Moo; end

      @user << :foo
      @user2 << [:joo, @foo]
      @user3 << [:qoo, Moo]

      acl do
        allow :foo, :boo,              :to => [:index, :show]
        allow :zoo, :joo, :by => :foo, :to => [:edit, :update]
        allow :qoo, :woo, :of => Moo
        deny  :qoo, :woo, :of => Moo,  :except => [:delete, :destroy]
      end.
      permit(@user, 'index').
      permit(@user, 'show').
      forbid(@user, 'edit').
      permit(@user2, 'edit', :foo => @foo).
      permit(@user2, 'update', :foo => @foo).
      forbid(@user2, 'show', :foo => @foo).
      forbid(@user2, 'show').
      permit(@user3, 'delete').
      permit(@user3, 'destroy').
      forbid(@user3, 'edit').
      forbid(@user3, 'show')
    end
  end

  describe "actions block" do
    it "should raise an ArgumentError when actions has no block" do
      arg_err do
        actions :foo, :bar
      end
    end

    it "should raise an ArgumentError when actions has no arguments" do
      arg_err do
        actions do end
      end
    end

    it "should raise an ArgumentError when actions is called inside actions block" do
      arg_err do
        actions :foo, :bar do
          actions :foo, :bar do
          end
        end
      end
    end

    it "should raise an ArgumentError when default is called inside actions block" do
      arg_err do
        actions :foo, :bar do
          default :allow
        end
      end
    end

    [:to, :except].each do |opt|
      it "should raise an ArgumentError when allow is called with #{opt} option" do
        arg_err do
          actions :foo do
            allow all, opt => :bar
          end
        end
      end

      it "should raise an ArgumentError when deny is called with #{opt} option" do
        arg_err do
          actions :foo do
            deny all, opt => :bar
          end
        end
      end
    end

    it "empty actions block should do nothing" do
      acl do
        actions :foo do
        end

        allow all
      end.permit(nil).permit(nil, :foo)
    end

    it "#allow should limit its scope to specified actions" do
      @user << :bee

      acl do
        actions :edit do
          allow :bee
        end
      end.
      permit(@user, :edit).
      forbid(@user, :update)
    end

    it "#deny should limit its scope to specified actions" do
      @user << :bee

      acl do
        default :allow
        actions :edit do
          deny :bee
        end
      end.
      forbid(@user, :edit).
      permit(@user, :update)
    end

    it "#allow and #deny should work together inside actions block" do
      @foo = ThatFoo.new
      @user << [:owner, @foo]
      @user2 << :hacker
      @user2 << :the_destroyer
      @user3 << [:owner, @foo]
      @user3 << :hacker

      list = acl do
        actions :show, :index do
          allow all
        end

        actions :edit, :update do
          allow :owner, :of => :object
          deny :hacker
        end

        actions :delete, :destroy do
          allow :owner, :of => :object
          allow :the_destroyer
        end
      end

      @all_actions = %w(show index edit update delete destroy)

      permit_some(list, @user,  @all_actions, :object => @foo)
      permit_some(list, @user2, %w(show index delete destroy))
      permit_some(list, @user3, %w(show index delete destroy), :object => @foo)
    end
    
    it "should work with anonymous" do
      @user << :superadmin
      
      list = acl do
        allow :superadmin
        
        action :index, :show do
          allow anonymous
        end
      end

      @all_actions = %w(show index edit update delete destroy)

      permit_some(list, @user, @all_actions)
      permit_some(list, nil, %w(index show))
    end
    
    it "should work with anonymous and other role inside" do
      @user << :superadmin
      @user2 << :member
      
      list = acl do
        allow :superadmin
        
        action :index, :show do
          allow anonymous
          allow :member
        end
      end

      @all_actions = %w(show index edit update delete destroy)

      permit_some(list, @user, @all_actions)
      permit_some(list, @user2, %w(index show))
      permit_some(list, nil, %w(index show))
    end
  end
end

