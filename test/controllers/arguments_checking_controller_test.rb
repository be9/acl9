require 'test_helper'

class ArgumentsCheckingControllerTest < ActionController::TestCase
  test "raise ArgumentError without a block" do
    assert_raise ArgumentError do
      class FailureController < ApplicationController
        access_control
      end
    end
  end

  test "raise ArgumentError with 1st argument which is not a symbol" do
    assert_raise ArgumentError do
      class FailureController < ApplicationController
        access_control 123 do end
      end
    end
  end

  test "raise ArgumentError with more than 1 positional argument" do
    assert_raise ArgumentError do
      class FailureController < ApplicationController
        access_control :foo, :bar do end
      end
    end
  end

  test "raise ArgumentError with helper: true and no method name" do
    assert_raise ArgumentError do
      class FailureController < ApplicationController
        access_control helper: true do end
      end
    end
  end

  test "raise ArgumentError with helper: :method and a method name" do
    assert_raise ArgumentError do
      class FailureController < ApplicationController
        access_control :meth, helper: :another_meth do end
      end
    end
  end
end
