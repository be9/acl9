class Account < ActiveRecord::Base
  acts_as_authorization_subject association_name: :roles, role_class_name: 'Access'
end
