module Other
  class User < ActiveRecord::Base
    acts_as_authorization_subject :association_name => :roles, :join_table_name => "other_roles_users", :role_class_name => "Other::Role"
  end
end
