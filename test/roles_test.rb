require 'test_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'acl9')
require 'support/models'

#Logger = ActiveRecord::Base.logger
load 'support/schema.rb'


class SystemRolesTest < Test::Unit::TestCase
  it "should not delete a system role" do
    Role.destroy_all
    @role=Role.create(:name=>"admin", :system=>true)
    @role.system.should be_true
    Role.count.should==1
    @user = User.create!
    @user.has_role!(:admin)
    Role.count.should==1
    @user.has_no_role!(:admin)
    Role.count.should==1
  end
end

class RolesTest < Test::Unit::TestCase
  before do
    Role.destroy_all
    [User, Foo, Bar].each { |model| model.delete_all }

    @user = User.create!
    @user2 = User.create!
    @foo = Foo.create!
    @bar = Bar.create!
    #create authorized object that has a string primary key
    @uuid = Uuid.new
    @uuid.uuid = "C41642EE-2780-0001-189F-17F3101B26E0"
    @uuid.save
  end

  it "should not have any roles by default" do
    %w(user manager admin owner).each do |role|
      @user.has_role?(role).should be_false
    end
  end

  it "#has_role! without object (global role)" do
    lambda do
      @user.has_role!('admin')
    end.should change { Role.count }.from(0).to(1)

    @user.has_role?('admin').should be_true
    @user2.has_role?('admin').should be_false
  end

  it "should not count global role as object role" do
    @user.has_role!('admin')

    [@foo, @bar, Foo, Bar, @user].each do |obj|
      @user.has_role?('admin', obj).should be_false
      @user.has_roles_for?(obj).should be_false
      @user.roles_for(obj).should == []
    end

    [@foo, @bar].each do |obj|
      obj.accepts_role?('admin', @user).should be_false
    end
  end

  it "#has_role! with object (object role)" do
    @user.has_role!('manager', @foo)

    @user.has_role?('manager', @foo).should be_true
    @user.has_roles_for?(@foo).should be_true
    @user.has_role_for?(@foo).should be_true

    roles = @user.roles_for(@foo)
    roles.should == @foo.accepted_roles_by(@user)
    roles.size.should == 1
    roles.first.name.should == "manager"

    @user.has_role?('manager', @bar).should be_false
    @user2.has_role?('manager', @foo).should be_false

    @foo.accepts_role?('manager', @user).should be_true
    @foo.accepts_role_by?(@user).should be_true
    @foo.accepts_roles_by?(@user).should be_true
  end

  it "should count object role also as global role" do
    @user.has_role!('manager', @foo)

    @user.has_role?('manager').should be_true
  end

  it "should not count object role as object class role" do
    @user.has_role!('manager', @foo)
    @user.has_role?('manager', Foo).should be_false
  end

  context "protect_global_roles is true" do
    before do
      @saved_option = Acl9.config[:protect_global_roles]
      Acl9.config[:protect_global_roles] = true
    end

    it "should not count object role also as global role" do
      @user.has_role!('manager', @foo)

      @user.has_role?('manager').should be_false
    end

    after do
      Acl9.config[:protect_global_roles] = @saved_option
    end
  end

  it "#has_role! with class" do
    @user.has_role!('user', Bar)

    @user.has_role?('user', Bar).should be_true
    @user.has_roles_for?(Bar).should be_true
    @user.has_role_for?(Bar).should be_true

    roles = @user.roles_for(Bar)
    roles.size.should == 1
    roles.first.name.should == "user"

    @user.has_role?('user', Foo).should be_false
    @user2.has_role?('user', Bar).should be_false
  end

  it "should not count class role as object role" do
    @user.has_role!('manager', Foo)
    @user.has_role?('manager', @foo).should be_false
  end

  it "should be able to have several roles on the same object" do
    @user.has_role!('manager', @foo)
    @user.has_role!('user',    @foo)
    @user.has_role!('admin',   @foo)

    @user.has_role!('owner',   @bar)

    @user.roles_for(@foo)        .map(&:name).sort.should == %w(admin manager user)
    @foo.accepted_roles_by(@user).map(&:name).sort.should == %w(admin manager user)
  end

  it "should reuse existing roles" do
    @user.has_role!('owner', @bar)
    @user2.has_role!('owner', @bar)

    @user.role_objects.should == @user2.role_objects
  end

  it "#has_no_role! should unassign a global role from user" do
    set_some_roles

    lambda do
      @user.has_no_role!('3133t')
    end.should change { @user.role_objects.count }.by(-1)

    @user.has_role?('3133t').should be_false
  end

  it "#has_no_role! should unassign an object role from user" do
    set_some_roles

    lambda do
      @user.has_no_role!('manager', @foo)
    end.should change { @user.role_objects.count }.by(-1)

    @user.has_role?('manager', @foo).should be_false
    @user.has_role?('user', @foo).should be_true      # another role on the same object
  end

  it "#has_no_role! should unassign a class role from user" do
    set_some_roles

    lambda do
      @user.has_no_role!('admin', Foo)
    end.should change { @user.role_objects.count }.by(-1)

    @user.has_role?('admin', Foo).should be_false
    @user.has_role?('admin').should be_true           # global role
  end

  it "#has_no_roles_for! should unassign global and class roles with nil object" do
    set_some_roles

    lambda do
      @user.has_no_roles_for!
    end.should change { @user.role_objects.count }.by(-4)

    @user.has_role?('admin').should be_false
    @user.has_role?('3133t').should be_false
    @user.has_role?('admin', Foo).should be_false
    @user.has_role?('manager', Foo).should be_false
  end

  it "#has_no_roles_for! should unassign object roles" do
    set_some_roles

    lambda do
      @user.has_no_roles_for! @foo
    end.should change { @user.role_objects.count }.by(-2)

    @user.has_role?('user', @foo).should be_false
    @user.has_role?('manager', @foo).should be_false
  end

  it "#has_no_roles_for! should unassign both class roles and object roles for objects of that class" do
    set_some_roles

    lambda do
      @user.has_no_roles_for! Foo
    end.should change { @user.role_objects.count }.by(-4)

    @user.has_role?('admin', Foo).should be_false
    @user.has_role?('manager', Foo).should be_false
    @user.has_role?('user', @foo).should be_false
    @user.has_role?('manager', @foo).should be_false
  end

  it "#has_no_roles! should unassign all roles" do
    set_some_roles

    @user.has_no_roles!
    @user.role_objects.count.should == 0
  end

  it "should delete unused roles from table" do
    @user.has_role!('owner', @bar)
    @user2.has_role!('owner', @bar)

    Role.count.should == 1

    @bar.accepts_no_role!('owner', @user2)
    Role.count.should == 1

    @bar.accepts_no_role!('owner', @user)

    Role.count.should == 0
  end

  it "should be able to get users that have a role on a authorized object" do
    @user.has_role!('owner', @bar)
    @user2.has_role!('owner', @bar)

    @bar.users.count.should == 2
  end

  it "should be able to get users that have a role on a authorized object with text primary key" do
    @user.has_role!('owner', @uuid)
    @user2.has_role!('owner', @uuid)

    @uuid.users.count.should == 2
  end

  it "should accept :symbols as role names" do
    @user.has_role! :admin
    @user.has_role! :_3133t

    @user.has_role! :admin, Foo
    @user.has_role! :manager, Foo
    @user.has_role! :user, @foo
    @foo.accepts_role! :manager, @user
    @bar.accepts_role! :owner,   @user

    @user.has_role?(:admin).should be_true
    @user.has_role?(:_3133t).should be_true
    @user.has_role?(:admin, Foo).should be_true
    @user.has_role?(:manager, @foo).should be_true
  end

  private

  def set_some_roles
    @user.has_role!('admin')
    @user.has_role!('3133t')

    @user.has_role!('admin', Foo)
    @user.has_role!('manager', Foo)
    @user.has_role!('user', @foo)
    @foo.accepts_role!('manager', @user)
    @bar.accepts_role!('owner',   @user)
  end
end


class RolesWithCustomClassNamesTest < Test::Unit::TestCase
  before do
    AnotherRole.destroy_all
    [AnotherSubject, FooBar].each { |model| model.delete_all }

    @subj = AnotherSubject.create!
    @subj2 = AnotherSubject.create!
    @foobar = FooBar.create!
  end

  it "should basically work" do
    lambda do
      @subj.has_role!('admin')
      @subj.has_role!('user', @foobar)
    end.should change { AnotherRole.count }.from(0).to(2)

    @subj.has_role?('admin').should be_true
    @subj2.has_role?('admin').should be_false

    @subj.has_role?(:user, @foobar).should be_true
    @subj2.has_role?(:user, @foobar).should be_false

    @subj.has_no_roles!
    @subj2.has_no_roles!
  end
end

class RolesWithCustomAssociationNamesTest < Test::Unit::TestCase
  before do
    DifferentAssociationNameRole.destroy_all
    [DifferentAssociationNameSubject, FooBar].each { |model| model.delete_all }

    @subj = DifferentAssociationNameSubject.create!
    @subj2 = DifferentAssociationNameSubject.create!
    @foobar = FooBar.create!
  end

  it "should basically work" do
    lambda do
      @subj.has_role!('admin')
      @subj.has_role!('user', @foobar)
    end.should change { DifferentAssociationNameRole.count }.from(0).to(2)

    @subj.has_role?('admin').should be_true
    @subj2.has_role?('admin').should be_false

    @subj.has_role?(:user, @foobar).should be_true
    @subj2.has_role?(:user, @foobar).should be_false

    @subj.has_no_roles!
    @subj2.has_no_roles!
  end
end

class UsersRolesAndSubjectsWithNamespacedClassNamesTest < Test::Unit::TestCase
  before do
    Other::Role.destroy_all
    [Other::User, Other::FooBar].each { |model| model.delete_all }

    @user = Other::User.create!
    @user2 = Other::User.create!
    @foobar = Other::FooBar.create!

  end

  it "should basically work" do
    lambda do
      @user.has_role!('admin')
      @user.has_role!('user', @foobar)
    end.should change { Other::Role.count }.from(0).to(2)

    @user.has_role?('admin').should be_true
    @user2.has_role?('admin').should be_false

    @user.has_role?(:user, @foobar).should be_true
    @user2.has_role?(:user, @foobar).should be_false

    @foobar.accepted_roles.count.should == 1

    @user.has_no_roles!
    @user2.has_no_roles!
  end
end
