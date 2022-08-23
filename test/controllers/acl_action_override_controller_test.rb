require 'test_helper'

class AclActionOverrideControllerTest < ActionController::TestCase
  test "anon can index" do
    assert get :check_allow, params: { _action: :index }
    assert_response :ok
  end

  test "anon can't show" do
    assert get :check_allow, params: { _action: :show }
    assert_response :unauthorized
  end

  test "normal user can't edit" do
    assert get :check_allow_with_foo, params: { _action: :edit, user_id: User.create.id }
    assert_response :unauthorized
  end

  test "foo owner can edit" do
    assert ( user = User.create ).has_role! :owner, Foo.first_or_create
    assert get :check_allow_with_foo, params: { _action: :edit, user_id: user.id }
    assert_response :ok
  end
end
