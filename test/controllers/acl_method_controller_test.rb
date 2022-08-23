require 'test_helper'

class AclMethodControllerTest < ActionController::TestCase
  include BaseTests
  include ShouldRespondToAcl
end
