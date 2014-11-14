require 'test_helper'

module ControllerExtensions
  class Base < ActiveSupport::TestCase
    setup do
      # TODO - clean this up so we don't need to create such a complex object just for a test
      @tester = Class.new(Acl9::Dsl::Base) do
        def check_allowance(subject, *args)
          @_subject = subject
          @_current_action = (args[0] || 'index').to_s
          @_objects = args.last.is_a?(Hash) ? args.last : {}
          @_callable = @_objects.delete(:call)

          instance_eval(allowance_expression)
        end

        def _subject_ref
          "@_subject"
        end

        def _object_ref(object)
          "@_objects[:#{object}]"
        end

        def _action_ref
          "@_current_action"
        end

        def _method_ref(method)
          "@_callable.send(:#{method})"
        end
      end.new
    end

    def permit_some(user, actions, vars = {})
      actions.each                  { |act| assert_permitted(user, act, vars) }
      (@all_actions - actions).each { |act| assert_forbidden(user, act, vars) }
    end

    def assert_permitted *args
      assert @tester.check_allowance *args
    end

    def assert_forbidden *args
      refute @tester.check_allowance *args
    end

    def assert_all_forbidden
      assert_forbidden nil
      assert_user_types_forbidden
    end

    def assert_all_permitted
      assert_permitted nil
      assert_user_types_permitted
    end

    def assert_user_types_forbidden
      assert @user = User.create
      assert_forbidden @user
      assert_admins_forbidden
    end

    def assert_admins_forbidden
      assert @user = User.first_or_create

      assert @user.has_role! :admin
      assert_forbidden @user

      assert @user.has_role! :admin, Foo
      assert_forbidden @user

      assert @user.has_role! :admin, Foo.first_or_create
      assert_forbidden @user
    end

    def assert_user_types_permitted
      assert @user = User.first_or_create
      assert_permitted @user
      assert_admins_permitted
    end

    def assert_admins_permitted
      assert @user = User.first_or_create

      assert @user.has_role! :admin
      assert_permitted @user

      assert @user.has_role! :admin, Foo
      assert_permitted @user

      assert @user.has_role! :admin, Foo.first_or_create
      assert_permitted @user
    end
  end
end
