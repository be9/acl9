require File.join(File.dirname(__FILE__), 'acl9', 'config')

if defined? ActiveRecord::Base
  require File.join(File.dirname(__FILE__), 'acl9', 'model_extensions')

  ActiveRecord::Base.send(:include, Acl9::ModelExtensions)
end


if defined? ActionController::Base
  require File.join(File.dirname(__FILE__), 'acl9', 'controller_extensions')
  require File.join(File.dirname(__FILE__), 'acl9', 'helpers')

  ActionController::Base.send(:include, Acl9::ControllerExtensions)
  Acl9Helpers = Acl9::Helpers unless defined?(Acl9Helpers)
end
