class CreateUuids < ActiveRecord::Migration
  def change
    create_table :uuids, :id => false do |t|
      t.string :uuid
      t.timestamps
    end

    add_index :uuids, :uuid, :unique => true
  end
end
