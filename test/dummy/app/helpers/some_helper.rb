module SomeHelper
  include Acl9Helpers

  access_control :the_question do
    allow :hamlet, :to => :be
    allow :hamlet, :except => :be
  end
end
