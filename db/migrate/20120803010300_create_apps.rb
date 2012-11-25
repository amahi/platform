class CreateApps < ActiveRecord::Migration
  def change
    create_table "apps" do |t|
      t.boolean  "installed"
      t.string   "name"
      t.string   "screenshot_url"
      t.string   "identifier"
      t.text     "description"
      t.string   "version"
      t.string   "app_url"
      t.string   "logo_url"
      t.integer  "webapp_id"
      t.string   "status"
      t.boolean  "show_in_dashboard",    :default => true
      t.string   "forum_url"
      t.integer  "theme_id"
      t.text     "special_instructions"
      t.integer  "db_id"
      t.integer  "server_id"
      t.integer  "share_id"
      t.string   "initial_user"
      t.string   "initial_password"
      t.timestamps
    end
  end
end
