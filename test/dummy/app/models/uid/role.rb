class Uid::Role < ActiveRecord::Base
  self.table_name = 'uid_roles'

  acts_as_authorization_role :join_table_name => :uid_roles_users

  attr_accessible :name, :authorizable, :authorizable_type, :authorizable_id
end
