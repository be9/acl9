class Bar < ActiveRecord::Base
  acts_as_authorization_subject :association_name => :uid_roles, :join_table_name => :uid_roles_users, :role_class_name => 'Uid::Role'
end
