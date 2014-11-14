class Role < ActiveRecord::Base
  acts_as_authorization_role
end
