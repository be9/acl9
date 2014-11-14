require_relative 'base'

module ControllerExtensions
  class RoleTest < Base
    test "allows admin implicit default" do
      @tester.acl_block! { allow :admin }
      
      assert_admins_permitted
      assert_forbidden nil

      assert ( user = User.create ).has_role! :cool
      assert_forbidden user
    end

    test "allow plural admins implicit default" do
      @tester.acl_block! do
        allow :admins
      end

      assert_admins_permitted
      assert_forbidden nil

      assert ( user = User.create ).has_role! :cool
      assert_forbidden user
    end

    test "allow with several roles" do
      assert ( cool1_user = User.create ).has_role! :cool
      assert ( cool2_user = User.create ).has_role! :cool
      assert ( super_user = User.create ).has_role! :super

      @tester.acl_block! do
        allow :admin
        allow :cool
      end
      
      assert_admins_permitted

      assert_permitted cool1_user
      assert_permitted cool2_user

      assert_forbidden nil
      assert_forbidden super_user
    end

    test "deny plural admins" do
      @tester.acl_block! do
        default :allow
        deny :admins
      end
      
      assert_permitted nil
      assert_permitted User.create
      assert_admins_forbidden
    end

    test "deny several roles" do
      assert ( cool1_user = User.create ).has_role! :cool
      assert ( cool2_user = User.create ).has_role! :cool
      assert ( super_user = User.create ).has_role! :super

      @tester.acl_block! do
        default :allow
        deny :admin
        deny :cool
      end
      
      assert_permitted nil
      assert_admins_forbidden
      assert_forbidden cool1_user
      assert_forbidden cool2_user
      assert_permitted super_user
    end
  end
end
