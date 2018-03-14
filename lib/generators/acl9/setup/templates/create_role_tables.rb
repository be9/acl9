class Create<%= role_class_name %>Tables < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :<%= role_table_name %> do |t|
      t.string   :name,                   null: false
      <% if r5? %>
      t.references :authorizable, polymorphic: true
      <% else %>
      t.string   :authorizable_type,      null: true
      t.integer  :authorizable_id,        null: true
      <% end %>
      t.boolean  :system, default: false, null: false
      t.timestamps                        null: false
    end

    add_index :<%= role_table_name %>, :name

    <% unless r5? %>
    add_index :<%= role_table_name %>, [:authorizable_type, :authorizable_id]
    <% end -%>

    create_table :<%= habtm_table %>, id: false do |t|
      t.references  :<%= subject_name %>, null: false
      t.references  :<%= role_name %>, null: false
    end

    <% unless r5? %>
    add_index :<%= habtm_table %>, :<%= subject_name %>_id
    add_index :<%= habtm_table %>, :<%= role_name %>_id
    <% end %>
  end
end
