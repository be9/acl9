class StringUser < ActiveRecord::Base
  acts_as_authorization_subject role_class_name: "StringObjectRole"
end
