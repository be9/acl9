require_relative 'acl_query_mixin'

class ACLQueryMethodWithLambdaTest < ActionController::TestCase
  test "should respond to :acl?" do
    assert @controller.respond_to? :acl?
  end

  include ACLQueryMixin
end
