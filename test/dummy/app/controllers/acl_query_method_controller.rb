class AclQueryMethodController < ApplicationController
  attr_accessor :current_user

  access_control :acl, :query_method => true do
    allow :editor, :to => [:edit, :update, :destroy]
    allow :viewer, :to => [:index, :show]
    allow :owner,  :of => :foo, :to => :fooize
  end
end
