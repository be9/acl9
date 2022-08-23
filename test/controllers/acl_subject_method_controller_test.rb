require 'test_helper'

class AclSubjectMethodControllerTest < ActionController::TestCase
  test "allow the only user to index" do
    assert ( user = User.create ).has_role! :the_only_one
    assert get :index, params: { user_id: user.id }
    assert_response :ok
  end

  test "deny anonymous to index" do
    assert_raises Acl9::AccessDenied do
      assert get :index
    end
  end
end
