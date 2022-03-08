require_relative 'base'

module ControllerExtensions
  class MultipleRoleArgumentsTest < Base
    test "#allow should be able to receive a role list (global roles)" do
      assert ( bzz = User.create ).has_role! :bzz
      assert ( whoa = User.create ).has_role! :whoa

      @tester.acl_block! do
        allow :bzz, :whoa
      end
      assert_permitted bzz
      assert_permitted whoa
      assert_forbidden nil
      assert_forbidden User.create
    end

    test "#allow should be able to receive a role list (object roles)" do
      assert foo = Foo.create
      assert foo_too = Foo.create

      assert ( maker = User.create ).has_role! :maker, foo
      assert ( faker = User.create ).has_role! :faker, foo_too

      @tester.acl_block! do
        allow :maker, :faker, :of => :foo
      end

      assert_permitted maker, :foo => foo
      assert_forbidden maker, :foo => foo_too
      assert_permitted faker, :foo => foo_too
      assert_forbidden faker, :foo => foo

      assert other = User.create
      assert_forbidden other, :foo => foo
      assert_forbidden other, :foo => foo_too
      assert_forbidden nil
    end

    test "#allow should be able to receive a role list (class roles)" do
      assert ( frooble = User.create ).has_role! :frooble, Foo
      assert ( oombigle = User.create ).has_role! :oombigle, Foo
      assert ( lame_frooble = User.create ).has_role! :frooble

      @tester.acl_block! do
        allow :frooble, :oombigle, :by => Foo
      end
      assert_permitted frooble
      assert_permitted oombigle
      assert_forbidden lame_frooble
      assert_forbidden nil
    end

    test "#deny should be able to receive a role list (global roles)" do
      assert ( bzz = User.create ).has_role! :bzz
      assert ( whoa = User.create ).has_role! :whoa

      @tester.acl_block! do
        default :allow
        deny :bzz, :whoa
      end
      
      assert_forbidden bzz
      assert_forbidden whoa
      assert_permitted nil
      assert_permitted User.create
    end

    test "#deny should be able to receive a role list (object roles)" do
      assert foo = Foo.create
      assert foo_too = Foo.create

      assert ( maker = User.create ).has_role! :maker, foo
      assert ( faker = User.create ).has_role! :faker, foo_too

      @tester.acl_block! do
        default :allow
        deny :maker, :faker, :of => :foo
      end

      assert_forbidden maker, :foo => foo
      assert_permitted maker, :foo => foo_too
      assert_forbidden faker, :foo => foo_too
      assert_permitted faker, :foo => foo

      assert other = User.create
      assert_permitted other, :foo => foo
      assert_permitted other, :foo => foo_too
      assert_permitted nil
    end

    test "#deny should be able to receive a role list (class roles)" do
      assert ( frooble = User.create ).has_role! :frooble, Foo
      assert ( oombigle = User.create ).has_role! :oombigle, Foo
      assert ( lame_frooble = User.create ).has_role! :frooble

      @tester.acl_block! do
        default :allow
        deny :frooble, :oombigle, :by => Foo
      end

      assert_forbidden frooble
      assert_forbidden oombigle
      assert_permitted lame_frooble
      assert_permitted nil
    end

    test "should also respect :to and :except" do
      assert foo = Foo.create

      assert ( foo = User.create ).has_role! :foo
      assert ( joo = User.create ).has_role! :joo, foo
      assert ( qoo = User.create ).has_role! :qoo, Bar

      @tester.acl_block! do
        allow :foo, :boo,              :to => [:index, :show]
        allow :zoo, :joo, :by => :foo, :to => [:edit, :update]
        allow :qoo, :woo, :of => Bar
        deny  :qoo, :woo, :of => Bar,  :except => [:delete, :destroy]
      end

      assert_permitted foo, 'index'
      assert_permitted foo, 'show'
      assert_forbidden foo, 'edit'
      assert_permitted joo, 'edit', :foo => foo
      assert_permitted joo, 'update', :foo => foo
      assert_forbidden joo, 'show', :foo => foo
      assert_forbidden joo, 'show'
      assert_permitted qoo, 'delete'
      assert_permitted qoo, 'destroy'
      assert_forbidden qoo, 'edit'
      assert_forbidden qoo, 'show'
    end
  end
end
