require File.join(File.dirname(__FILE__), 'model_extensions', 'for_subject')
require File.join(File.dirname(__FILE__), 'model_extensions', 'for_object')

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
      #   user.roles             #=> returns Role objects, associated with the user
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
        join_table = options[:join_table_name] || Acl9::config[:default_join_table_name] ||
                    join_table_name(undecorated_table_name(self.to_s), undecorated_table_name(role))

        has_and_belongs_to_many assoc, :class_name => role, :join_table => join_table

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
        subj_col = subject.underscore

        role       = options[:role_class_name] || Acl9::config[:default_role_class_name]
        role_table = role.constantize.table_name

        join_table = ActiveRecord::Base.send(:join_table_name, role_table, subj_table)

        sql_tables = <<-EOS
          FROM #{subj_table}
          INNER JOIN #{join_table} ON #{subj_col}_id = #{subj_table}.id
          INNER JOIN #{role_table} ON #{role_table}.id = #{role.underscore}_id
        EOS

        sql_where = <<-'EOS'
          WHERE authorizable_type = '#{self.class.base_class.to_s}'
          AND authorizable_id = #{column_for_attribute(self.class.primary_key).text? ? "'#{id}'": id}
        EOS

        has_many :accepted_roles, :as => :authorizable, :class_name => role, :dependent => :destroy

        has_many :"#{subj_table}",
          :finder_sql  => ("SELECT DISTINCT #{subj_table}.*" + sql_tables + sql_where),
          :counter_sql => ("SELECT COUNT(DISTINCT #{subj_table}.id)" + sql_tables + sql_where),
          :readonly => true

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
                     join_table_name(undecorated_table_name(self.to_s), undecorated_table_name(subject))

        has_and_belongs_to_many subject.demodulize.tableize.to_sym,
          :class_name => subject,
          :join_table => join_table

        belongs_to :authorizable, :polymorphic => true
      end
    end
  end
end
