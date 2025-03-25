require 'ostruct'
require_relative 'base'

module ControllerExtensions
  class ConditionsTest < Base
    [:if, :unless].each do |cond|
      test "should raise ArgumentError when #{cond} is not a Symbol" do
         assert_raise ArgumentError do
          @tester.acl_block! { allow nil, cond => 123 }
        end
      end
    end

    test "allow ... :if" do
      @tester.acl_block! do
        allow nil, :if => :meth
      end
      assert_permitted nil, :call => OpenStruct.new(:meth => true)
      assert_forbidden nil, :call => OpenStruct.new(:meth => false)
    end

    test "allow ... :unless" do
      @tester.acl_block! do
        allow nil, :unless => :meth
      end
      assert_permitted nil, :call => OpenStruct.new(:meth => false)
      assert_forbidden nil, :call => OpenStruct.new(:meth => true)
    end

    test "deny ... :if" do
      @tester.acl_block! do
        default :allow
        deny nil, :if => :meth
      end
      assert_permitted nil, :call => OpenStruct.new(:meth => false)
      assert_forbidden nil, :call => OpenStruct.new(:meth => true)
    end

    test "deny ... :unless" do
      @tester.acl_block! do
        default :allow
        deny nil, :unless => :meth
      end
      assert_permitted nil, :call => OpenStruct.new(:meth => true)
      assert_forbidden nil, :call => OpenStruct.new(:meth => false)
    end

  end
end
