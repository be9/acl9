require 'test_helper'

class AclObjectsHashControllerTest < ActionController::TestCase
  setup do
    assert @user = User.create
    assert @user.has_role! :owner, Foo.first_or_create
  end

  test "objects hash preferred to @ivar" do
    assert get :allow, params: { user_id: @user.id }
    assert_response :ok
  end

  test "unauthed for no user" do
    assert get :allow
    assert_response :unauthorized
  end
end
