require 'test_helper'

class RolesWithCustomClassNamesTest < ActiveSupport::TestCase
  setup do
    Access.destroy_all
    [Account, FooBar].each { |model| model.delete_all }

    @subj = Account.create!
    @subj2 = Account.create!
    @foobar = FooBar.create!
  end

  test "should basically work" do
    assert_difference -> { Access.count }, 2 do
      assert @subj.has_role! :admin
      assert @subj.has_role! :user, @foobar
    end

    assert @subj.has_role? :admin
    refute @subj2.has_role? :admin

    assert @subj.has_role? :user, @foobar
    refute @subj2.has_role? :user, @foobar

    assert @subj.has_no_roles!
    assert @subj2.has_no_roles!
  end
end
