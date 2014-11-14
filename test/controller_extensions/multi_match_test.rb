require_relative 'base'

module ControllerExtensions
  class MultiMatchTest < Base
    test "default when nothing else matches" do
      @tester.acl_block! do
        default :allow
        allow :blah
        deny :bzz
      end

      assert_equal :allow, @tester.default_action
      assert_all_permitted
    end

    test "should deny when deny is matched, but allow is not" do
      @tester.acl_block! do
        default :allow
        deny all
        allow :blah
      end
      
      assert_all_forbidden
    end

    test "allow allowed and deny denied and default for unmatched" do
      assert ( cool_user = User.create ).has_role! :cool
      assert ( jerk_user = User.create ).has_role! :jerk

      @tester.acl_block! do
        default :allow
        deny :jerk
        allow :cool
      end
      
      assert_forbidden jerk_user
      assert_permitted cool_user
      assert_all_permitted
    end

    test "allowed by default when both match" do
      assert ( cool_user = User.create ).has_role! :cool
      assert ( jerk_user = User.create ).has_role! :jerk

      @tester.acl_block! do
        default :allow
        deny :cool
        allow :cool
      end

      assert_permitted cool_user
      assert_permitted jerk_user
      assert_all_permitted
    end

    test "allowed by default when both all" do
      assert ( cool_user = User.create ).has_role! :cool
      assert ( jerk_user = User.create ).has_role! :jerk

      @tester.acl_block! do
        default :allow
        deny all
        allow all
      end

      assert_permitted cool_user
      assert_permitted jerk_user
      assert_all_permitted
    end

    test "allow logged_in allows user not anon" do
      @tester.acl_block! do
        allow logged_in
      end
      
      assert_forbidden nil
      assert_user_types_permitted
    end

    test "deny logged_in denies user not anon" do
      @tester.acl_block! do
        default :allow
        deny logged_in
      end
      
      assert_permitted nil
      assert_user_types_forbidden
    end

    test "denies unmatched when default deny" do
      @tester.acl_block! do
        default :deny
        allow :blah
        deny :bzz
      end
      
      assert_all_forbidden
    end

    test "deny all when allow unmatched" do
      @tester.acl_block! do
        default :allow
        deny all
        allow :blah
      end

      assert_all_forbidden
    end

    test "allow when allow matches and deny doesn't" do
      @tester.acl_block! do
        default :deny
        deny nil
        allow :admin
      end

      assert_admins_permitted
    end

    test "denied by default when both match" do
      assert ( user = User.create ).has_role! :cool

      @tester.acl_block! do
        default :deny
        deny :cool
        allow :cool
      end
      
      assert_forbidden user
    end

    test "denied by default when both all" do
      @tester.acl_block! do
        default :deny
        deny all
        allow all
      end

      assert_all_forbidden
    end
  end
end
