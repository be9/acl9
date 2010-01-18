ActiveRecord::Schema.define(:version => 0) do
  create_table "roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.boolean "system", :default=>false
    t.string   "authorizable_type", :limit => 40
    t.string  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "another_roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "different_association_name_roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t| end
  create_table "another_subjects", :force => true do |t| end
  create_table "different_association_name_subjects", :force => true do |t| end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "another_roles_another_subjects", :id => false, :force => true do |t|
    t.integer  "another_subject_id"
    t.integer  "another_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "different_association_name_roles_different_association_name_subjects", :id => false, :force => true do |t|
    t.integer  "different_association_name_subject_id"
    t.integer  "different_association_name_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "foos", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uuids", :id => false, :force => true do |t|
    t.string "uuid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
  create_table "bars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  create_table "foo_bars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  # namespaced
  
  create_table "other_roles", :force => true do |t|
    t.string   "name",              :limit => 40
    t.string   "authorizable_type", :limit => 40
    t.integer  "authorizable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  create_table "other_users", :force => true do |t| end
  create_table "other_roles_other_users", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  create_table "other_foo_bars", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end
  
end
