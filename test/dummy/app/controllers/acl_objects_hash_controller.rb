class AclObjectsHashController < ApplicationController
  access_control :allowed?, :filter => false do
    allow :owner, :of => :foo
  end

  def allow
    @foo = nil
    head allowed?( :foo => Foo.find_by_id(params[:user_id]) ) ? :ok : :unauthorized
  end
end
