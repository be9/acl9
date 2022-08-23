class AclQueryMethodWithLambdaController < ApplicationController
  attr_accessor :current_user

  access_control :query_method => :acl? do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end
