module Acl9
  @@config = {
    :default_role_class_name => 'Role',
    :default_subject_class_name => 'User',
    :default_subject_method => :current_user,
    :default_association_name => :role_objects,
    :protect_global_roles => false,
  }

  mattr_reader :config
end
