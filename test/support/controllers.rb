
class ACLQueryMethod < ApplicationController
  attr_accessor :current_user

  access_control :acl, :query_method => true do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end

class ACLQueryMethodWithLambda < ApplicationController
  attr_accessor :current_user

  access_control :query_method => :acl? do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end

class ACLNamedQueryMethod < ApplicationController
  attr_accessor :current_user

  access_control :acl, :query_method => 'allow_ay' do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end

  def acl?(*args)
    allow_ay(*args)
  end
end
