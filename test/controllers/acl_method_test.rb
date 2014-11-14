require 'test_helper'

class ACLMethodTest < ActionController::TestCase
  include BaseTests
  include ShouldRespondToAcl
end
