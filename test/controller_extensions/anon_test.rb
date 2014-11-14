require_relative 'base'

module ControllerExtensions
  class AnonTest < Base
    test "allow nil permits only nil" do
      @tester.acl_block! { allow nil }

      assert_permitted nil
      assert_user_types_forbidden
    end

    test "allow anon permits only nil" do
      @tester.acl_block! { allow anonymous }

      assert_permitted nil
      assert_user_types_forbidden
    end

    test "default allowed, nil denied" do
      @tester.acl_block! do
        default :allow
        deny nil
      end

      assert_forbidden nil
      assert_user_types_permitted
    end

    test "default allowed, anon denied" do
      @tester.acl_block! do
        default :allow
        deny anonymous
      end

      assert_forbidden nil
      assert_user_types_permitted
    end
  end
end
