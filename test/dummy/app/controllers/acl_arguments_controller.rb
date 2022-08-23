class AclArgumentsController < EmptyController
  access_control :except => [:index, :show] do
    allow :admin, :if => :true_meth, :unless => :false_meth
  end

  private

  def true_meth; true end
  def false_meth; false end
end
