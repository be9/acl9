require 'test_helper'

class RolesTest < ActiveSupport::TestCase
  setup do
    assert @user = User.create
    assert @user2 = User.create
    assert @foo = Foo.create
    assert @bar = Bar.create
  end

  test "should not have any roles by default" do
    %w(user manager admin owner).each do |role|
      refute @user.has_role? role
    end
  end

  test "#has_role! without object (global role)" do
    assert_difference -> { Role.count } do
      assert @user.has_role! :admin
    end

    assert @user.has_role? :admin
    refute @user2.has_role? :admin
  end

  test "should not count global role as object role" do
    assert @user.has_role! :admin

    [@foo, @bar, Foo, Bar, @user].each do |obj|
      refute @user.has_role? :admin, obj
      refute @user.has_roles_for?(obj)
      assert_equal [], @user.roles_for(obj)
    end

    [@foo, @bar].each do |obj|
      refute obj.accepts_role? :admin, @user
    end
  end

  test "#has_role! with object (object role)" do
    assert @user.has_role! :manager, @foo

    assert @user.has_role? :manager, @foo
    assert @user.has_roles_for? @foo
    assert @user.has_role_for? @foo

    assert roles = @user.roles_for( @foo )
    assert_equal roles, @foo.accepted_roles_by(@user)
    assert_equal 1, roles.size
    assert_equal 'manager', roles.first.name

    refute @user.has_role? :manager, @bar
    refute @user2.has_role? :manager, @foo

    assert @foo.accepts_role? :manager, @user
    assert @foo.accepts_role_by? @user
    assert @foo.accepts_roles_by? @user
  end

  test "should count object role also as global role" do
    assert @user.has_role! :manager, @foo
    assert @user.has_role? :manager
  end

  test "should not count object role as object class role" do
    assert @user.has_role! :manager, @foo
    refute @user.has_role? :manager, Foo
  end

  test "don't count object role as global when protect_global_roles == true" do
    saved_option = Acl9.config[:protect_global_roles]
    Acl9.config[:protect_global_roles] = true

    assert @user.has_role! :manager, @foo
    refute @user.has_role? :manager

    Acl9.config[:protect_global_roles] = saved_option
  end

  test "#has_role! with class" do
    assert @user.has_role! :user, Bar

    assert @user.has_role? :user, Bar
    assert @user.has_roles_for? Bar
    assert @user.has_role_for? Bar

    assert roles = @user.roles_for( Bar)
    assert_equal 1, roles.size
    assert_equal "user", roles.first.name

    refute @user.has_role? :user, Foo
    refute @user2.has_role? :user, Bar
  end

  test "should not count class role as object role" do
    assert @user.has_role! :manager, Foo
    refute @user.has_role? :manager, @foo
  end

  test "should be able to have several roles on the same object" do
    assert @user.has_role! :manager, @foo
    assert @user.has_role! :user,    @foo
    assert @user.has_role! :admin,   @foo

    assert @user.has_role! :owner,   @bar

    assert_equal_elements %w(admin manager user), @user.roles_for(@foo).map(&:name)
    assert_equal_elements %w(admin manager user), @foo.accepted_roles_by(@user).map(&:name)
  end

  test "should reuse existing roles" do
    @user.has_role! :owner, @bar
    @user2.has_role! :owner, @bar

    assert_equal @user2.role_objects, @user.role_objects
  end

  test "#has_no_role! should unassign a global role from user" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -1 do
      assert @user.has_no_role! '3133t'
    end

    refute @user.has_role? '3133t'
  end

  test "#has_no_role! should unassign an object role from user" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -1 do
      assert @user.has_no_role! :manager, @foo
    end

    refute @user.has_role? :manager, @foo
    assert @user.has_role? :user, @foo      # another role on the same object
  end

  test "#has_no_role! should unassign a class role from user" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -1 do
      assert @user.has_no_role! :admin, Foo
    end

    refute @user.has_role? :admin, Foo
    assert @user.has_role? :admin           # global role
  end

  test "#has_no_roles_for! should unassign global and class roles with nil object" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -4 do
      assert @user.has_no_roles_for!
    end

    refute @user.has_role? :admin
    refute @user.has_role? '3133t'
    refute @user.has_role? :admin, Foo
    refute @user.has_role? :manager, Foo
  end

  test "#has_no_roles_for! should unassign object roles" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -2 do
      assert @user.has_no_roles_for! @foo
    end

    refute @user.has_role? :user, @foo
    refute @user.has_role? :manager, @foo
  end

  test "#has_no_roles_for! should unassign both class roles and object roles for objects of that class" do
    set_some_roles

    assert_difference -> { @user.role_objects.count }, -4 do
      assert @user.has_no_roles_for! Foo
    end

    refute @user.has_role? :admin, Foo
    refute @user.has_role? :manager, Foo
    refute @user.has_role? :user, @foo
    refute @user.has_role? :manager, @foo
  end

  test "#has_no_roles! should unassign all roles" do
    set_some_roles

    @user.has_no_roles!
    assert_equal 0, @user.role_objects.count
  end

  test "should delete unused roles from table" do
    assert @user.has_role! :owner, @bar
    assert @user2.has_role! :owner, @bar

    assert_equal 1, Role.count

    @bar.accepts_no_role! :owner, @user2
    assert_equal 1, Role.count

    @bar.accepts_no_role! :owner, @user

    assert_equal 0, Role.count
  end

  test "should be able to get users that have a role on a authorized object" do
    assert @user.has_role! :owner, @bar
    assert @user2.has_role! :owner, @bar

    assert_equal 2, @bar.users.count
  end

  test "should be able to get users that have a role on a authorized object with text primary key" do
    assert uuid = Uuid.create( id: "C41642EE-2780-0001-189F-17F3101B26E0" )

    assert @user.has_role! :owner, uuid
    assert @user2.has_role! :owner, uuid

    assert_equal 2, uuid.users.count
  end

  test "should accept :symbols as role names" do
    assert @user.has_role! :admin
    assert @user.has_role! :_3133t

    assert @user.has_role! :admin, Foo
    assert @user.has_role! :manager, Foo
    assert @user.has_role! :user, @foo
    assert @foo.accepts_role! :manager, @user
    assert @bar.accepts_role! :owner,   @user

    assert @user.has_role?(:admin)
    assert @user.has_role?(:_3133t)
    assert @user.has_role?(:admin, Foo)
    assert @user.has_role?(:manager, @foo)
  end

  private

  def set_some_roles
    assert @user.has_role! :admin
    assert @user.has_role! '3133t'

    assert @user.has_role! :admin, Foo
    assert @user.has_role! :manager, Foo
    assert @user.has_role! :user, @foo
    assert @foo.accepts_role! :manager, @user
    assert @bar.accepts_role! :owner,   @user
  end
end
