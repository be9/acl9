require 'test_helper'

class HelperTest < ActionView::TestCase
  setup do
    @helper = Class.new do
      include ActionView::Helpers
      include SomeHelper

      attr_accessor :current_user
      attr_accessor :action_name
      def controller
        self
      end

      def set_hamlet
        ( self.current_user = User.create ).has_role! :hamlet
      end
    end.new

  end

  test "has :the_question method" do
    assert @helper.respond_to? :the_question
  end

  test "role :hamlet is allowed to be" do
    assert @helper.set_hamlet

    assert @helper.action_name = 'be'
    assert @helper.the_question
  end

  test "role :hamlet is allowed to not_be" do
    assert @helper.set_hamlet

    assert @helper.action_name = 'not_be'
    assert @helper.the_question
  end

  test "not logged in is not allowed to be" do
    assert_nil @helper.current_user = nil

    assert @helper.action_name = 'be'
    refute @helper.the_question
  end

  test "noone is not allowed to be" do
    assert ( @helper.current_user = User.create )

    assert @helper.action_name = 'be'
    refute @helper.the_question
  end

  test "has :show_to method" do
    assert @helper.respond_to? :show_to
  end

  test "has :show_to hamlet 'hello hamlet' message" do
    assert @helper.set_hamlet

    assert message = 'hello hamlet'
    assert_equal message, @helper.show_to('hamlet') { message }
  end

  test "has to show message if user has hamlet role on object" do
    assert foo = Foo.create
    assert ( @helper.current_user = User.create ).has_role! :hamlet, foo

    assert message = 'hello hamlet'
    assert_equal message, @helper.show_to(:hamlet, :of => foo) { message }
  end

  test "has not to show message if user has no hamlet role on object" do
    assert @helper.set_hamlet

    assert foo = Foo.create
    assert @helper.current_user.has_role! :hamlet, foo

    assert_nil @helper.show_to('hamlet', :of => Foo.new) { 'hello my prince' }
  end

  test "has :show_to nothing to NotLoggedIn" do
    assert_nil @helper.current_user = nil

    assert @helper.action_name = 'be'
    assert message = 'hello hamlet'
    assert_nil @helper.show_to(:hamlet) { message }
  end
end
