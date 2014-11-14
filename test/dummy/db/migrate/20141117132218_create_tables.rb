class CreateTables < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string   :name,              :limit => 40
      t.boolean  :system
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end

    add_index :roles, [:authorizable_type, :authorizable_id]

    create_table :roles_users, id: false do |t|
      t.references  :user
      t.references  :role
      t.timestamps
    end

    add_index :roles_users, :user_id
    add_index :roles_users, :role_id
    
    create_table :users do |t|
      t.string :name
      t.timestamps
    end

    create_table :foos do |t|
      t.string :name
      t.timestamps
    end

    create_table :bars do |t|
      t.string :name
      t.timestamps
    end

    create_table :uuids, id: false do |t|
      t.string :uuid, primary_key: true
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.string :name
      t.timestamps
    end

    create_table :accesses do |t|
      t.string :name
      t.boolean  :system
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end

    add_index :accesses, [:authorizable_type, :authorizable_id]

    create_table :accesses_accounts, id: false do |t|
      t.references  :account
      t.references  :access
      t.timestamps
    end

    add_index :accesses_accounts, :access_id
    add_index :accesses_accounts, :account_id

    create_table :foo_bars do |t|
      t.string :name
      t.timestamps
    end


    create_table :other_roles do |t|
      t.string   :name,              :limit => 40
      t.boolean  :system
      t.string   :authorizable_type, :limit => 40
      t.integer  :authorizable_id
      t.timestamps
    end

    add_index :other_roles, [:authorizable_type, :authorizable_id]

    create_table :other_roles_users, id: false do |t|
      t.references  :user
      t.references  :role
      t.timestamps
    end

    add_index :other_roles_users, :user_id
    add_index :other_roles_users, :role_id
    
    create_table :other_users do |t|
      t.string :name
      t.timestamps
    end

    create_table :other_foos do |t|
      t.string :name
      t.timestamps
    end
  end
end
