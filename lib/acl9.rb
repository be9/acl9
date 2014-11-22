require 'acl9/version'
require 'acl9/model_extensions'
require 'acl9/controller_extensions'
require 'acl9/helpers'

module Acl9
  @@config = {
    :default_role_class_name    => 'Role',
    :default_subject_class_name => 'User',
    :default_subject_method     => :current_user,
    :default_association_name   => :role_objects,
    :protect_global_roles       => true,
  }

  mattr_reader :config
end

ActiveRecord::Base.send(:include, Acl9::ModelExtensions)
ActionController::Base.send(:include, Acl9::ControllerExtensions)
Acl9Helpers = Acl9::Helpers unless defined?(Acl9Helpers)
