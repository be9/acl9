require 'test_helper'

class ConfigTest < ActiveSupport::TestCase
  teardown do
    Acl9.config.reset!
  end

  test "configure block API" do
    assert new_method = :fruitcake
    Acl9.configure do |c|
      assert c.default_subject_method = new_method
    end

    assert_equal new_method, Acl9.config.default_subject_method
    assert_equal new_method, Acl9.config[:default_subject_method]
    assert_equal new_method, Acl9::config[:default_subject_method]
  end

  test "method API" do
    assert new_method = :seesaw
    Acl9.config.default_subject_method = new_method

    assert_equal new_method, Acl9.config.default_subject_method
    assert_equal new_method, Acl9.config[:default_subject_method]
    assert_equal new_method, Acl9::config[:default_subject_method]
  end

  test "hash API" do
    assert new_method = :sandcastle
    assert Acl9.config[:default_subject_method] = new_method

    assert_equal new_method, Acl9.config.default_subject_method
    assert_equal new_method, Acl9.config[:default_subject_method]
    assert_equal new_method, Acl9::config[:default_subject_method]
  end

  test "reset!" do
    assert new_method = :bluesky
    assert Acl9.config.default_subject_method = new_method

    assert Acl9.config.reset!

    refute_equal new_method, Acl9.config.default_subject_method
  end

  test "errors when missing option" do
    assert_raises NoMethodError do
      Acl9.config[:does_not_exist] = :foo
    end

    assert_raises NoMethodError do
      Acl9.config[:does_not_exist]
    end
  end
end
