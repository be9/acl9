class User < ActiveRecord::Base
  acts_as_authorization_subject :association_name => :roles
end
