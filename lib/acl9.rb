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

    def merge! h
      h.each { |k,v| self[k.to_sym] = v }
    end
  end

  @@config = Config.new( *CONFIG.values_at(*Config.members))

  mattr_reader :config

  def self.configure
    yield config
  end

  class ArgumentError < ArgumentError; end
  class RuntimeError < RuntimeError; end
  class NilObjectError < RuntimeError; end

  ##
  # This exception is raised whenever ACL block finds that the current user
  # is not authorized for the controller action he wants to execute.
  # @example How to catch this exception in ApplicationController
  #   class ApplicationController < ActionController::Base
  #     rescue_from 'Acl9::AccessDenied', :with => :access_denied
  #
  #     # ...other stuff...
  #     private
  #
  #     def access_denied
  #       if current_user
  #         # It's presumed you have a template with words of pity and regret
  #         # for unhappy user who is not authorized to do what he wanted
  #         render :template => 'home/access_denied'
  #       else
  #         # In this case user has not even logged in. Might be OK after login.
  #         flash[:notice] = 'Access denied. Try to log in first.'
  #         redirect_to login_path
  #       end
  #     end
  #   end
  #
  class AccessDenied < RuntimeError; end

  ##
  # This exception is raised when acl9 has generated invalid code for the
  # filtering method or block. Should never happen, and it's a bug when it
  # happens.
  class FilterSyntaxError < ArgumentError; end

end

ActiveRecord::Base.send(:include, Acl9::ModelExtensions)
AbstractController::Base.send :include, Acl9::ControllerExtensions
Acl9Helpers = Acl9::Helpers unless defined?(Acl9Helpers)
