class Uuid < ActiveRecord::Base
  self.primary_key = "uuid"  
  acts_as_authorization_object role_class_name: "StringObjectRole", subject_class_name: "StringUser"
end
