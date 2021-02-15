class CreateTables < ActiveRecord::Migration[ActiveRecord::Migration.current_version]
  def self.r5?
    Rails.gem_version >= Gem::Version.new(5)
  end
  def r5?
    self.class.r5?
  end

  def change
    create_table :roles do |t|
      t.string   :name,              :limit => 40
      t.boolean  :system
      if r5?
        t.references :authorizable, polymorphic: true
      else
        t.string   :authorizable_type, :limit => 40
        t.integer  :authorizable_id
      end
      t.timestamps null: false
    end

    unless r5?
      add_index :roles, [:authorizable_type, :authorizable_id]
    end

    create_table :roles_users, id: false do |t|
      t.references  :user
      t.references  :role
    end

    unless r5?
      add_index :roles_users, :user_id
      add_index :roles_users, :role_id
    end

    create_table :users do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :foos do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :bars do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :uuids, id: false do |t|
      t.string :uuid, primary_key: true
      t.string :name
      t.timestamps null: false
    end

    create_table :string_object_roles do |t|
      t.string :name
      t.boolean  :system
      t.string   :authorizable_type
      t.string   :authorizable_id
      t.timestamps null: false
    end

    create_table :string_object_roles_string_users, id: false do |t|
      t.references  :string_user, index: { name: "susor" }
      t.references  :string_object_role, index: { name: "sorsu" }
    end

    create_table :string_users do |t|
      t.string :name
      t.timestamps null: false
    end


    create_table :accounts do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :accesses do |t|
      t.string :name
      t.boolean  :system
      if r5?
        t.references :authorizable, polymorphic: true
      else
        t.string   :authorizable_type, :limit => 40
        t.integer  :authorizable_id
      end
      t.timestamps null: false
    end

    unless r5?
      add_index :accesses, [:authorizable_type, :authorizable_id]
    end

    create_table :accesses_accounts, id: false do |t|
      t.references  :account
      t.references  :access
    end

    unless r5?
      add_index :accesses_accounts, :access_id
      add_index :accesses_accounts, :account_id
    end

    create_table :foo_bars do |t|
      t.string :name
      t.timestamps null: false
    end


    create_table :other_roles do |t|
      t.string   :name,              :limit => 40
      t.boolean  :system
      if r5?
        t.references :authorizable, polymorphic: true
      else
        t.string   :authorizable_type, :limit => 40
        t.integer  :authorizable_id
      end
      t.timestamps null: false
    end

    unless r5?
      add_index :other_roles, [:authorizable_type, :authorizable_id]
    end

    create_table :other_roles_users, id: false do |t|
      t.references  :user
      t.references  :role
    end

    unless r5?
      add_index :other_roles_users, :user_id
      add_index :other_roles_users, :role_id
    end

    create_table :other_users do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :other_foos do |t|
      t.string :name
      t.timestamps null: false
    end
  end
end
