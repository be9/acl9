class Role < ActiveRecord::Base
  acts_as_authorization_role
end

class User < ActiveRecord::Base
  acts_as_authorization_subject
end

class Foo < ActiveRecord::Base
  acts_as_authorization_object
end

class Uuid < ActiveRecord::Base
  set_primary_key "uuid"  
  acts_as_authorization_object
end

class Bar < ActiveRecord::Base
  acts_as_authorization_object
end

class AnotherSubject < ActiveRecord::Base
  acts_as_authorization_subject :role_class_name => 'AnotherRole'
end

class AnotherRole < ActiveRecord::Base
  acts_as_authorization_role :subject_class_name => "AnotherSubject"
end

class FooBar < ActiveRecord::Base
  acts_as_authorization_object :role_class_name => 'AnotherRole', :subject_class_name => "AnotherSubject"
end

class DifferentAssociationNameSubject < ActiveRecord::Base
	acts_as_authorization_subject :association_name => 'roles', :role_class_name => "DifferentAssociationNameRole"
end

class DifferentAssociationNameRole < ActiveRecord::Base
	acts_as_authorization_role :subject_class_name => "DifferentAssociationNameSubject"
end

module Other

  class Other::User < ActiveRecord::Base
    set_table_name "other_users"
    acts_as_authorization_subject :join_table_name => "other_roles_other_users", :role_class_name => "Other::Role"
  end

  class Other::Role < ActiveRecord::Base
    set_table_name "other_roles"
    acts_as_authorization_role :join_table_name => "other_roles_other_users", :subject_class_name => "Other::User"
  end

  class Other::FooBar < ActiveRecord::Base
    set_table_name "other_foo_bars"
    acts_as_authorization_object :role_class_name => 'Other::Role', :subject_class_name => "Other::User"
  end

end
