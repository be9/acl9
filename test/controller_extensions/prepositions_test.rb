require_relative 'base'

module ControllerExtensions
  class PrepositionsTest < Base

    %i[of for in on at by].each do |prep|
      test "allow :#{prep} => :foo checks @foo" do
        assert @foo = Foo.first_or_create
        assert ( user = User.create ).has_role! :manager, @foo

        @tester.acl_block! do
          allow :manager, prep => :foo
        end

        assert other_foo = Foo.create

        assert_permitted user, :foo => @foo
        assert_forbidden user, :foo => other_foo
        assert_forbidden user, :foo => Foo
        assert_forbidden nil, :foo => @foo
        assert_forbidden User.create, :foo => @foo
      end

      test "invalid allow :#{prep} arg raises ArgumentError" do
        assert_raise ArgumentError do
          @tester.acl_block! { allow :hom, :by => 1 }
        end
      end
    end

    test "allow class role allowed" do
      assert ( user = User.create ).has_role! :owner, Foo

      @tester.acl_block! do
        allow :owner, :of => Foo
      end

      assert_permitted user
      assert_forbidden nil
      assert_forbidden User.create
    end

    %i[of for in on at by].each do |prep|
      test "deny :#{prep} => :foo checks @foo" do
        assert @foo = Foo.first_or_create
        assert ( user = User.create ).has_role! :thief, @foo

        @tester.acl_block! do
          default :allow
          deny :thief, prep => :foo
        end

        assert_forbidden user, :foo => @foo
        assert_permitted user, :foo => Foo.create
        assert_permitted user, :foo => Foo
        assert_permitted nil, :foo => @foo
        assert_permitted User.create, :foo => @foo
      end

      test "invalid deny :#{prep} arg raises ArgumentError" do
        assert_raise ArgumentError do
          @tester.acl_block! { deny :her, :for => "him" }
        end
      end
    end

    test "deny class role denied" do
      assert ( user = User.create ).has_role! :ignorant, Foo

      @tester.acl_block! do
        default :allow
        deny :ignorant, :of => Foo
      end
      
      assert_forbidden user, Foo
      assert_permitted nil
      assert_permitted User.create
    end

    test "> 1 allow prepositions raises ArgumentError" do
      assert_raise ArgumentError do
        @tester.acl_block! { allow :some, :by => :one, :for => :another }
      end
    end

    test "> 1 deny prepositions raises ArgumentError" do
      assert_raise ArgumentError do
        @tester.acl_block! { deny :some, :in => :here, :on => :today }
      end
    end

    test "should raise an ArgumentError when both :to and :except are specified" do
      assert_raise ArgumentError do
        @tester.acl_block! { allow all, :to => :index, :except => ['show', 'edit'] }
      end
    end

  end
end
