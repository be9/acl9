require 'test_helper'

class VersionTest < Test::Unit::TestCase
  it "Should have a version" do
    assert defined? Acl9::VERSION
  end
end
