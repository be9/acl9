class Uuid < ActiveRecord::Base
  self.primary_key = 'uuid'

  acts_as_authorization_object
end
