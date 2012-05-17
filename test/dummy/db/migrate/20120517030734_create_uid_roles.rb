class CreateUidRoles < ActiveRecord::Migration
  def change
    create_table :uid_roles do |t|
      t.string :name
      t.string :authorizable_type
      t.string :authorizable_id
      t.timestamps
    end
  end
end
