class AclBlockController < EmptyController
  access_control :debug => true do
    allow all, :to => [:index, :show]
    allow :admin
  end
end
