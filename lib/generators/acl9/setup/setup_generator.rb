require "rails/generators/active_record"

module Acl9
  class SetupGenerator < Rails::Generators::Base
    include ActiveRecord::Generators::Migration

    source_root File.expand_path('../templates', __FILE__)

    argument :arg_subject, type: :string, default: 'user', banner: "subject"
    argument :arg_role, type: :string, default: 'role', banner: "role"
    argument :arg_objects, type: :array, default: [], banner: "objects..."

    def create_migration
      next_migration_number = self.class.next_migration_number( File.expand_path( '../db/migrate', __FILE__))
      template "create_role_tables.rb", "db/migrate/#{next_migration_number}_create_#{role_name}_tables.rb"
    end

    def create_models
      template "role.rb", "app/models/#{role_name}.rb"

      objects.each do |object|
        my_inject "app/models/#{object}.rb", object.classify, "  #{object_helper}\n"
      end

      my_inject "app/models/#{subject_name}.rb", subject_class_name, "  #{subject_helper}\n"
    end

    def create_initializer
      initializer "acl9.rb" do
        <<-RUBY.strip_heredoc
        # See https://github.com/be9/acl9#configuration for details
        #
        # Acl9::config.merge!(
        #   :default_role_class_name    => 'Role',
        #   :default_subject_class_name => 'User',
        #   :default_subject_method     => :current_user,
        #   :default_association_name   => :role_objects,
        #   :protect_global_roles       => true,
        # )
        RUBY
      end
    end

    private
    def role_name
      arg_role.underscore.singularize
    end

    def role_table_name
      role_name.tableize
    end

    def role_class_name
      role_name.classify
    end

    def habtm_table
      [ subject_name, role_name ].sort.map(&:pluralize).join '_'
    end

    def subject_helper
      "acts_as_authorization_subject" + ( subject_options ? " #{subject_options}" : '' )
    end

    def object_helper
      "acts_as_authorization_object" + ( object_options ? " #{object_options}" : '' )
    end

    def role_helper
      "acts_as_authorization_role" + ( role_options ? " #{role_options}" : '' )
    end

    def my_inject file_name, class_name, string
      inject_into_class file_name, class_name, string
    rescue Errno::ENOENT
      create_file file_name do
        <<-RUBY.strip_heredoc
        class #{class_name} < ActiveRecord::Base
        #{string}
        end
        RUBY
      end
    end

    def role_options
      if defined?(Acl9::config) && Acl9::config[:default_subject_class_name].to_s.classify != subject_class_name
        "subject_class_name: #{subject_class_name}"
      end
    end

    def subject_options
      if defined?(Acl9::config) && Acl9::config[:default_role_class_name].to_s.classify != role_class_name
        "role_class_name: #{role_class_name}"
      end
    end

    def object_options
      [ role_options, subject_options ].compact.join ', '
    end

    def subject_name
      @subject_name ||= arg_subject.underscore.singularize
    end

    def objects
      @objects ||= arg_objects.map{|o|o.underscore.singularize}
    end

    def subject_class_name
      subject_name.classify
    end
  end
end
