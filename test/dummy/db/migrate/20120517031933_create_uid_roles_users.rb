class CreateUidRolesUsers < ActiveRecord::Migration
  def change
    create_table :uid_roles_users, :id => false do |t|
      t.references  :bar
      t.references  :role
    end
  end
end
