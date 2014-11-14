# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140724203948) do

  create_table "roles", :force => true do |t|
    t.string   :name,              :limit => 40
    t.string   :authorizable_type, :limit => 40
    t.integer  :authorizable_id
    t.timestamps
  end

  add_index :roles, [:authorizable_type, :authorizable_id]

  create_table "roles_users", :id => false, :force => true do |t|
    t.references  :user
    t.references  :role
    t.timestamps
  end

  add_index :roles_users, :user_id
  add_index :roles_users, :role_id
  
  create_table "users", :force => true do |t|
    t.string :name
    t.timestamps
  end
end
