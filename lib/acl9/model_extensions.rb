require_relative "model_extensions/for_subject"
require_relative "model_extensions/for_object"

module Acl9
  module ModelExtensions  #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Add #has_role? and other role methods to the class.
      # Makes a class a auth. subject class.
      #
      # @param [Hash] options the options for tuning
      # @option options [String] :role_class_name (Acl9::config[:default_role_class_name])
      #                           Class name of the role class (e.g. 'AccountRole')
      # @option options [String] :join_table_name (Acl9::config[:default_join_table_name])
      #                           Join table name (e.g. 'accounts_account_roles')
      # @option options [String] :association_name (Acl9::config[:default_association_name])
      #                           Association name (e.g. ':roles')
      # @example
      #   class User < ActiveRecord::Base
      #     acts_as_authorization_subject
      #   end
      #
      #   user = User.new
      #   user.role_objects      #=> returns Role objects, associated with the user
      #   user.has_role!(...)
      #   user.has_no_role!(...)
      #
      #   # other functions from Acl9::ModelExtensions::Subject are made available
      #
      # @see Acl9::ModelExtensions::Subject
      #
      def acts_as_authorization_subject(options = {})
        assoc = options[:association_name] || Acl9::config[:default_association_name]
        role = options[:role_class_name] || Acl9::config[:default_role_class_name]
        join_table = options[:join_table_name] || Acl9::config[:default_join_table_name] || self.table_name_prefix + [undecorated_table_name(self.to_s), undecorated_table_name(role)].sort.join("_") + self.table_name_suffix

        has_and_belongs_to_many assoc.to_sym, :class_name => role, :join_table => join_table

        before_destroy :has_no_roles!

        cattr_accessor :_auth_role_class_name, :_auth_subject_class_name,
                       :_auth_role_assoc_name

        self._auth_role_class_name = role
        self._auth_subject_class_name = self.to_s
        self._auth_role_assoc_name = assoc

        include Acl9::ModelExtensions::ForSubject
      end

      # Add role query and set methods to the class (making it an auth object class).
      #
      # @param [Hash] options the options for tuning
      # @option options [String] :subject_class_name (Acl9::config[:default_subject_class_name])
      #                          Subject class name (e.g. 'User', or 'Account)
      # @option options [String] :role_class_name (Acl9::config[:default_role_class_name])
      #                          Role class name (e.g. 'AccountRole')
      # @example
      #   class Product < ActiveRecord::Base
      #     acts_as_authorization_object
      #   end
      #
      #   product = Product.new
      #   product.accepted_roles #=> returns Role objects, associated with the product
      #   product.users          #=> returns User objects, associated with the product
      #   product.accepts_role!(...)
      #   product.accepts_no_role!(...)
      #   # other functions from Acl9::ModelExtensions::Object are made available
      #
      # @see Acl9::ModelExtensions::Object
      #
      def acts_as_authorization_object(options = {})
        subject = options[:subject_class_name] || Acl9::config[:default_subject_class_name]
        subj_table = subject.constantize.table_name

        role = options[:role_class_name] || Acl9::config[:default_role_class_name]

        has_many :accepted_roles, :as => :authorizable, :class_name => role, :dependent => :destroy

        subj_assoc = "assoc_#{subj_table}".to_sym
        has_many subj_assoc, -> { distinct.readonly }, source: subj_table.to_sym, through: :accepted_roles

        define_method subj_table.to_sym do |role_name=nil|
          rel = send subj_assoc

          if role_name
            rel = rel.where role.constantize.table_name.to_sym => { name: role_name }
          end
          rel
        end

        include Acl9::ModelExtensions::ForObject
      end

      # Make a class an auth role class.
      #
      # You'll probably never create or use objects of this class directly.
      # Various auth. subject and object methods will do that for you
      # internally.
      #
      # @param [Hash] options the options for tuning
      # @option options [String] :subject_class_name (Acl9::config[:default_subject_class_name])
      #                          Subject class name (e.g. 'User', or 'Account)
      # @option options [String] :join_table_name (Acl9::config[:default_join_table_name])
      #                           Join table name (e.g. 'accounts_account_roles')
      #
      # @example
      #   class Role < ActiveRecord::Base
      #     acts_as_authorization_role
      #   end
      #
      # @see Acl9::ModelExtensions::Subject#has_role!
      # @see Acl9::ModelExtensions::Subject#has_role?
      # @see Acl9::ModelExtensions::Subject#has_no_role!
      # @see Acl9::ModelExtensions::Object#accepts_role!
      # @see Acl9::ModelExtensions::Object#accepts_role?
      # @see Acl9::ModelExtensions::Object#accepts_no_role!
      def acts_as_authorization_role(options = {})
        subject = options[:subject_class_name] || Acl9::config[:default_subject_class_name]
        join_table = options[:join_table_name] || Acl9::config[:default_join_table_name] ||
                    self.table_name_prefix + [undecorated_table_name(self.to_s), undecorated_table_name(subject)].sort.join("_") + self.table_name_suffix
                    # comment out use deprecated API
                    #join_table_name(undecorated_table_name(self.to_s), undecorated_table_name(subject))

        has_and_belongs_to_many subject.demodulize.tableize.to_sym,
          :class_name => subject,
          :join_table => join_table

        belongs_to :authorizable, :polymorphic => true
      end
    end
  end
end
