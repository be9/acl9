class AclQueryMethodNamedController < ApplicationController
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
