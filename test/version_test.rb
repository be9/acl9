require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  test "has a version" do
    assert defined? Acl9::VERSION
  end
end
