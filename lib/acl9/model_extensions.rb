require File.join(File.dirname(__FILE__), 'model_extensions', 'subject')
require File.join(File.dirname(__FILE__), 'model_extensions', 'object')

module Acl9
  module ModelExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_authorization_subject(options = {})
        role = options[:role_class_name] || Acl9::config[:default_role_class_name]
        has_and_belongs_to_many :roles, :class_name => role

        cattr_accessor :_auth_role_class_name
        self._auth_role_class_name = role

        include Acl9::ModelExtensions::Subject 
      end

      def acts_as_authorization_object(options = {})
        subject = options[:subject_class_name] || Acl9::config[:default_subject_class_name]
        subj_table = subject.tableize
        subj_col = subject.underscore

        role       = options[:role_class_name] || Acl9::config[:default_role_class_name]
        role_table = role.tableize

        sql_tables = <<-EOS
          FROM #{subj_table}
          INNER JOIN #{role_table}_#{subj_table} ON #{subj_col}_id = #{subj_table}.id
          INNER JOIN #{role_table}               ON #{role_table}.id = #{role.underscore}_id
        EOS

        sql_where = <<-'EOS'
          WHERE authorizable_type = '#{self.class.base_class.to_s}'
          AND authorizable_id = #{id}
        EOS
        
        has_many :accepted_roles, :as => :authorizable, :class_name => role, :dependent => :destroy

        has_many :"#{subj_table}",
          :finder_sql  => ("SELECT DISTINCT #{subj_table}.*" + sql_tables + sql_where),
          :counter_sql => ("SELECT COUNT(DISTINCT #{subj_table}.id)" + sql_tables + sql_where),
          :readonly => true
        
        include Acl9::ModelExtensions::Object
      end

      def acts_as_authorization_role(options = {})
        subject = options[:subject_class_name] || Acl9::config[:default_subject_class_name]

        has_and_belongs_to_many subject.tableize.to_sym
        belongs_to :authorizable, :polymorphic => true
      end
    end
  end
end
