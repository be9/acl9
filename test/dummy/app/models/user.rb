class User < ActiveRecord::Base
  acts_as_authorization_subject :association_name => :roles, :join_table_name => :roles_users

  attr_accessible :username
end
