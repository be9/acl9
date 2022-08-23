require 'test_helper'

class AclIvarsControllerTest < ActionController::TestCase
  test "owner of foo destroys" do
    assert ( user = User.create ).has_role! :owner, Bar
    assert delete :destroy, params: { id: 1, user_id: user.id }
    assert_response :ok
  end

  test "bartender at Foo destroys" do
    assert ( user = User.create ).has_role! :bartender, Foo
    assert delete :destroy, params: { id: 1, user_id: user.id }
    assert_response :ok
  end
end
