class FooBar < ActiveRecord::Base
  acts_as_authorization_object :role_class_name => 'Access', :subject_class_name => 'Account'
end
