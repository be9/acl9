require 'test_helper'

class SystemRolesTest < ActiveSupport::TestCase
  test "should not delete a system role" do
    assert role = Role.create( :name => "admin", :system => true)
    assert role.system
    assert_equal 1, Role.count

    assert user = User.create
    assert user.has_role! :admin
    assert_equal 1, Role.count

    refute user.has_no_role! :admin
    assert_equal 1, Role.count
  end
end
