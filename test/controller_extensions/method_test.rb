require_relative 'base'

module ControllerExtensions
  class MethodTest < Base
    def run_tests
      %w(index show).each                 { |act| assert_permitted nil, act }
      %w(edit update delete destroy).each { |act| assert_forbidden nil, act }

      %w(index show edit update).each { |act| assert_permitted @manager, act }
      %w(delete destroy).each         { |act| assert_forbidden @manager, act }

      %w(index show edit update delete destroy).each { |act| assert_permitted @trusted, act }
    end

    test "should raise an ArgumentError when both :to and :except are specified" do
      assert_raise ArgumentError do
        @tester.acl_block! { allow all, :to => :index, :except => ['show', 'edit'] }
      end
    end

    test ":to should limit rule scope to specified actions" do
      assert ( @manager = User.create ).has_role! :manager
      assert ( @trusted = User.create ).has_role! :trusted

      @tester.acl_block! do
        allow all,       :to => [:index, :show]

        allow 'manager', :to => :edit
        allow 'manager', :to => 'update'
        allow 'trusted', :to => %w(edit update delete destroy)
      end

      run_tests
    end

    test ":except should limit rule scope to all actions except specified" do
      assert ( @manager = User.create ).has_role! :manager
      assert ( @trusted = User.create ).has_role! :trusted

      @tester.acl_block! do
        allow all,       :except => %w(edit update delete destroy)

        allow 'manager', :except => %w(delete destroy)
        allow 'trusted'
      end

      run_tests
    end
  end
end
