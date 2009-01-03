class Role < ActiveRecord::Base
  acts_as_authorization_role
end

class User < ActiveRecord::Base
  acts_as_authorization_subject
end

class Foo < ActiveRecord::Base
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
