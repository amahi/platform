class AddIndicesToTables < ActiveRecord::Migration[5.0]
  def change
    add_index :app_dependencies, :app_id
    add_index :app_dependencies, :dependency_id
    add_index :apps, :webapp_id
    add_index :apps, :theme_id
    add_index :apps, :db_id
    add_index :apps, :server_id
    add_index :apps, :share_id
    add_index :apps, :plugin_id
    add_index :cap_accesses, :user_id
    add_index :cap_accesses, :share_id
    add_index :cap_writers, :user_id
    add_index :cap_writers, :share_id
    add_index :webapp_aliases, :webapp_id
    add_index :webapps, :dns_alias_id
  end
end
