class AclActionOverrideController < ApplicationController
  access_control :allowed?, filter: false do
    allow all, to: :index
    deny all, to: :show
    allow :owner, of: :foo, to: :edit
  end

  def check_allow
    head allowed?(params[:_action]) ? :ok : :unauthorized
  end

  def check_allow_with_foo
    head allowed?(params[:_action], foo: Foo.first) ? :ok : :unauthorized
  end
end
