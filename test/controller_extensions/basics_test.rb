require_relative 'base'

module ControllerExtensions
  class BasicsTest < Base
    test "empty default denies" do
      @tester.acl_block! { }
      assert_equal :deny, @tester.default_action
      assert_all_forbidden
    end

    test "deny default denies" do
      @tester.acl_block! { default :deny }
      assert_equal :deny, @tester.default_action
      assert_all_forbidden
    end

    test "allow default allows" do
      @tester.acl_block! { default :allow }
      assert_equal :allow, @tester.default_action
      assert_all_permitted
    end

    test "error with bad args" do
      assert_raise ArgumentError do
        @tester.acl_block! { default 123 }
      end

      assert_raise ArgumentError do
        @tester.acl_block! do
          default :deny
          default :deny
        end
      end

      assert_raise ArgumentError do
        @tester.acl_block! { allow }
      end

      assert_raise ArgumentError do
        @tester.acl_block! { deny }
      end
    end
  end
end
