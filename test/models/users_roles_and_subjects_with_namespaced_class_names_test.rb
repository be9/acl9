require 'test_helper'

class UsersRolesAndSubjectsWithNamespacedClassNamesTest < ActiveSupport::TestCase
  setup do
    assert Other::Role.destroy_all
    [Other::User, Other::Foo].each { |model| model.delete_all }

    assert @user = Other::User.create!
    assert @user2 = Other::User.create!
    assert @foobar = Other::Foo.create!
  end

  test "should basically work" do
    assert_difference -> { Other::Role.count }, 2 do
      assert @user.has_role! :admin
      assert @user.has_role! :user, @foobar
    end

    assert @user.has_role?('admin')
    refute @user2.has_role?('admin')

    assert @user.has_role?(:user, @foobar)
    refute @user2.has_role?(:user, @foobar)

    assert_equal 1, @foobar.accepted_roles.count

    @user.has_no_roles!
    @user2.has_no_roles!
  end
end
