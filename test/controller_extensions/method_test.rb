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

    test "should raise an ArgumentError when either :to or :only and :except are specified" do
      %i[to only].each do |only|
        assert_raise ArgumentError do
          @tester.acl_block! { allow all, only => :index, :except => ['show', 'edit'] }
        end
      end
    end

    test ":to and :only should combine in union" do
      assert ( @manager = User.create ).has_role! :manager
      assert ( @trusted = User.create ).has_role! :trusted

      @tester.acl_block! do
        allow all,      :only => :index, :to => :show

        allow 'manager', :only => :edit, :to => 'edit'
        allow 'manager', :to => 'update', :only => :update
        allow 'trusted', :only => %w(edit update destroy), :to => %w(edit delete)
      end

      run_tests
    end


    test ":to and :only should limit rule scope to specified actions" do
      assert ( @manager = User.create ).has_role! :manager
      assert ( @trusted = User.create ).has_role! :trusted

      %i[to only].each do |only|
        @tester.acl_block! do
          allow all,       only => [:index, :show]

          allow 'manager', only => :edit
          allow 'manager', only => 'update'
          allow 'trusted', only => %w(edit update delete destroy)
        end

        run_tests
      end
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
