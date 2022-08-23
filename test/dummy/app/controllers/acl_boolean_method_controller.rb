class AclBooleanMethodController < EmptyController
  access_control :acl, filter: false do
    allow all, to: [:index, :show], if: :true_meth
    allow :admin,               unless: :false_meth
    allow all,                      if: :false_meth
    allow all,                  unless: :true_meth
  end

  before_action :check_acl

  def check_acl
    if self.acl
      true
    else 
      raise Acl9::AccessDenied
    end
  end

  private

  def true_meth; true end
  def false_meth; false end
end
