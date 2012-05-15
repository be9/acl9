require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup { @user = Factory.create :user }

  context "User can be assigned roles" do
    should "be able to be assigned a role" do
      assert @user.has_role!( :admin )
      assert @user.has_role?( :admin )
    end

    should "be able to query user roles" do
      assert @user.has_role!( :admin )
      assert @user.has_role?( :admin )
      assert ! @user.has_role?( :owner )
    end
  end

  context "User can own objects" do
    setup { @obj = Foo.create! }

    should "be able to own an object" do
      assert @user.has_role!( :owner, @obj )
      assert @user.has_role?( :owner, @obj )
      assert @user.has_role?( :owner )
    end

    should "be able to have different roles on same object" do
      assert @user.has_role!( :owner, @obj )
      assert @user.has_role!( :admin, @obj )
      assert @user.has_role!( :editor, @obj )

      assert roles = @user.roles_for( @obj )

      %w/owner admin editor/.each do |role|
        assert roles.map( &:name ).include? role
      end
    end
  end

  context "When protected roles are not global" do
    setup { Acl9.config[:protect_global_roles] = true }

    should "protect global roles" do
      assert obj = Foo.create!
      assert @user.has_role!( :owner, obj )
      assert @user.has_role?( :owner, obj )
      assert ! @user.has_role?( :owner )
    end
  end

  context "Can have role on a class" do
    should "work on classes" do
      assert @user.has_role!( :admin, Foo )
      assert @user.has_roles_for?( Foo )
      assert @user.has_role_for?( Foo )

      assert roles = @user.roles_for( Foo )
      assert_equal 1, roles.size
      assert_equal 'admin', roles.first.name
    end
  end
end
