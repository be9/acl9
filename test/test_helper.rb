ENV["RAILS_ENV"] = "test"

require 'minitest/autorun'

$VERBOSE = nil

require "logger"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers! if ENV["BACKTRACE"]

ActiveRecord::Migration.verbose = false

ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__)).migrate

class ActionController::TestCase
  setup do
    assert Foo.create
  end

  class << self
    def test_allowed method, action, params={}
      test "allowed #{method} #{action}" do
        if block_given?
          yield user = User.create
          params.merge! user_id: user.id
        end
        assert send( method, action, params: params )
        assert_response :ok
      end
    end

    def test_denied method, action, params={}
      test "denied #{method} #{action}" do
        assert_raises Acl9::AccessDenied do
          if block_given?
            yield user = User.create
            params.merge! user_id: user.id
          end
          assert send( method, action, params: params )
        end
      end
    end
  end
end

class ActiveSupport::TestCase
  def assert_equal_elements expected, test, message=nil
    assert_equal [], expected - test, message
  end
end

module BaseTests
  def self.included(klass)
    klass.class_eval do
      test_allowed :get, :index
      test_allowed :get, :show, id: 1
      test_denied :get, :new
      test_denied :get, :edit, id: 1
      test_denied :post, :create
      test_denied :put, :update, id: 1
      test_denied :patch, :update, id: 1
      test_denied :delete, :destroy, id: 1

      admin = -> (user) { user.has_role! :admin }
      test_allowed :get, :new, &admin
      test_allowed :get, :edit, id: 1, &admin
      test_allowed :post, :create, &admin
      test_allowed :put, :update, id: 1, &admin
      test_allowed :patch, :update, id: 1, &admin
      test_allowed :delete, :destroy, id: 1, &admin
    end
  end
end

module ShouldRespondToAcl
  def self.included(klass)
    klass.class_eval do
      test "#{klass} has :acl method" do
        assert @controller.respond_to? :acl
      end

      test "#{klass} has no :acl? method" do
        refute @controller.respond_to? :acl?
      end
    end
  end
end
