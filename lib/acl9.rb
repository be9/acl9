require 'acl9/version'
require 'acl9/model_extensions'
require 'acl9/controller_extensions'
require 'acl9/helpers'

module Acl9
  CONFIG = {
    :default_role_class_name    => 'Role',
    :default_subject_class_name => 'User',
    :default_subject_method     => :current_user,
    :default_association_name   => :role_objects,
    :default_join_table_name    => nil,
    :protect_global_roles       => true,
    :normalize_role_names       => true,
  }.freeze

  class Config < Struct.new(*CONFIG.keys )
    def [] k; send k.to_sym; end
    def []= k, v; send "#{k}=", v; end
    def reset!
      Acl9::CONFIG.each do |k,v|
        send "#{k}=", v
      end
    end
  end

  @@config = Config.new( *CONFIG.values_at(*Config.members))

  mattr_reader :config

  def self.configure
    yield config
  end
end

ActiveRecord::Base.send(:include, Acl9::ModelExtensions)
ActionController::Base.send(:include, Acl9::ControllerExtensions)
Acl9Helpers = Acl9::Helpers unless defined?(Acl9Helpers)
