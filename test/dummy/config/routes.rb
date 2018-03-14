Dummy::Application.routes.draw do
  resources :acl_action_override do
    collection do
      get :check_allow_with_foo
      get :check_allow
    end
  end

  resources :acl_boolean_method, :acl_block, :acl_ivars, :acl_method, :acl_method2, :acl_subject_method, :acl_arguments

  get :acl_helper_method, to: "acl_helper_method#allow"
  get :acl_objects_hash, to: "acl_objects_hash#allow"

end
