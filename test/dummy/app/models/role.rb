class Role < ActiveRecord::Base
  acts_as_authorization_role :join_table_name => :roles_users

  attr_accessible :name, :authorizable, :authorizable_type, :authorizable_id
end
