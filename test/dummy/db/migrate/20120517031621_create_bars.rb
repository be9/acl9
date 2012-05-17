class CreateBars < ActiveRecord::Migration
  def change
    create_table :bars do |t|

      t.timestamps
    end
  end
end
