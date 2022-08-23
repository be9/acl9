class AclIvarsController < EmptyController

  before_action :set_ivars

  access_control do
    action :destroy do
      allow :owner, of: :foo
      allow :bartender, at: Foo
    end
  end

  private

  def set_ivars
    @foo = Bar
  end
end
