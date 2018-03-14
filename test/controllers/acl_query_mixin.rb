require 'test_helper'

module ACLQueryMixin
  def self.included base
    base.class_eval do
      setup do
        assert ( @editor = User.create ).has_role! :editor
        assert ( @viewer = User.create ).has_role! :viewer
        assert ( @owneroffoo = User.create ).has_role! :owner, Foo.first_or_create
      end

      %i[edit update destroy].each do |meth|
        test "should return true for editor/#{meth}" do
          assert @controller.current_user = @editor
          assert @controller.acl? meth
          assert @controller.acl? meth.to_s
        end

        test "should return false for viewer/#{meth}" do
          assert @controller.current_user = @viewer
          refute @controller.acl? meth
          refute @controller.acl? meth.to_s
        end
      end

      %i[index show].each do |meth|
        test "should return false for editor/#{meth}" do
          assert @controller.current_user = @editor
          refute @controller.acl? meth
          refute @controller.acl? meth.to_s
        end

        test "should return true for viewer/#{meth}" do
          assert @controller.current_user = @viewer
          assert @controller.acl? meth
          assert @controller.acl? meth.to_s
        end
      end

      test "should return false for editor/fooize" do
        assert @controller.current_user = @editor
        refute @controller.acl? :fooize
      end

      test "should return true for foo owner" do
        assert @controller.current_user = @owneroffoo
        assert @controller.acl? :fooize, foo: Foo.first
      end
    end
  end
end
