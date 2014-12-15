require 'test_helper'

class SystemRolesTest < ActiveSupport::TestCase
  test "should not delete a system role" do
    assert role = Role.create( :name => "admin", :system => true)
    assert role.system
    assert_equal 1, Role.count

    assert user = User.create
    assert_difference -> { Role.count }, 0 do
      assert user.has_role! :admin
    end

    assert user.has_role? :admin

    assert_difference -> { Role.count }, 0 do
      assert user.has_no_role! :admin
    end

    refute user.has_role? :admin
  end
end
