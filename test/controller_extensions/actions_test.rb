require_relative 'base'

module ControllerExtensions
  class ActionTest < Base
    test "should raise an ArgumentError when actions has no block" do
      assert_raise ArgumentError do
        @tester.acl_block! { actions :foo, :bar }
      end
    end

    test "should raise an ArgumentError when actions has no arguments" do
      assert_raise ArgumentError do
        @tester.acl_block! { actions do end }
      end
    end

    test "should raise an ArgumentError when actions is called inside actions block" do
      assert_raise ArgumentError do
        @tester.acl_block! do
          actions :foo, :bar do
            actions :foo, :bar do
            end
          end
        end
      end
    end

    test "should raise an ArgumentError when default is called inside actions block" do
      assert_raise ArgumentError do
        @tester.acl_block! do
          actions :foo, :bar do
            default :allow
          end
        end
      end
    end

    [:to, :except].each do |opt|
      test "should raise an ArgumentError when allow is called with #{opt} option" do
        assert_raise ArgumentError do
          @tester.acl_block! do
            actions :foo do
              allow all, opt => :bar
            end
          end
        end
      end

      test "should raise an ArgumentError when deny is called with #{opt} option" do
        assert_raise ArgumentError do
          @tester.acl_block! do
            actions :foo do
              deny all, opt => :bar
            end
          end
        end
      end
    end

    test "empty actions block should do nothing" do
      @tester.acl_block! do
        actions :foo do
        end

        allow all
      end
      assert_permitted nil
      assert_permitted nil, :foo
    end

    test "#allow should limit its scope to specified actions" do
      assert ( bee = User.create ).has_role! :bee

      @tester.acl_block! do
        actions :edit do
          allow :bee
        end
      end
      assert_permitted bee, :edit
      assert_forbidden bee, :update
    end

    test "#deny should limit its scope to specified actions" do
      assert ( bee = User.create ).has_role! :bee

      @tester.acl_block! do
        default :allow
        actions :edit do
          deny :bee
        end
      end
      assert_forbidden bee, :edit
      assert_permitted bee, :update
    end

    test "#allow and #deny should work together inside actions block" do
      assert @foo = Foo.create

      assert ( owner = User.create ).has_role! :owner, @foo
      assert ( hacker = User.create ).has_role! :hacker
      assert hacker.has_role! :the_destroyer

      assert ( another_owner = User.create ).has_role! :owner, @foo
      assert another_owner.has_role! :hacker

      @tester.acl_block! do
        actions :show, :index do
          allow all
        end

        actions :edit, :new, :create, :update do
          allow :owner, :of => :foo
          deny :hacker
        end

        actions :destroy do
          allow :owner, :of => :foo
          allow :the_destroyer
        end
      end

      assert set_all_actions
      permit_some owner,  @all_actions
      permit_some hacker, %w(show index destroy)
      permit_some another_owner, %w(show index destroy)
    end

    def set_all_actions
      @all_actions = %w(index show new edit create update destroy)
    end

    test "should work with anonymous" do
      assert ( superadmin = User.create ).has_role! :superadmin

      @tester.acl_block! do
        allow :superadmin

        action :index, :show do
          allow anonymous
        end
      end

      assert set_all_actions
      permit_some superadmin, @all_actions
      permit_some nil, %w(index show)
    end

    test "should work with anonymous and other role inside" do
      assert ( superadmin = User.create ).has_role! :superadmin
      assert ( member = User.create ).has_role! :member

      @tester.acl_block! do
        allow :superadmin

        action :index, :show do
          allow anonymous
          allow :member
        end
      end

      assert set_all_actions
      permit_some superadmin, @all_actions
      permit_some member, %w(index show)
      permit_some nil, %w(index show)
    end
  end
end
