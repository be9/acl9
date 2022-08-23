class AclMethodController < EmptyController
  access_control :as_method => :acl do
    allow all, :to => [:index, :show]
    allow :admin, :except => [:index, :show]
  end
end
