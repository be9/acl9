require_relative 'base'

module ControllerExtensions
  class PseudoRoleTest < Base
    %i[all everyone everybody anyone].each do |pseudorole|
      test "allow #{pseudorole} allows all" do
        @tester.acl_block! do
          allow send pseudorole
        end

        assert_equal :deny, @tester.default_action
        assert_all_permitted
      end

      test "deny #{pseudorole} denies all" do
        @tester.acl_block! do
          default :allow
          deny send pseudorole
        end

        assert_equal :allow, @tester.default_action
        assert_all_forbidden
      end
    end
  end
end
