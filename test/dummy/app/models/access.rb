class Access < ActiveRecord::Base
  acts_as_authorization_role :subject_class_name => "Account"
end
