module Other
  class Role < ActiveRecord::Base
    acts_as_authorization_role :join_table_name => "other_roles_users", :subject_class_name => "Other::User"
  end
end
