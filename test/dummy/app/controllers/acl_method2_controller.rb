class AclMethod2Controller < EmptyController
  access_control :acl do
    allow all, :to => [:index, :show]
    allow :admin, :except => [:index, :show]
  end
end
