class CreateShares < ActiveRecord::Migration[5.1]
	def change
    create_table "shares" do |t|
      t.string   "name"
      t.string   "path"
      t.boolean  "rdonly"
      t.boolean  "visible"
      t.boolean  "everyone",         :default => true
      t.string   "tags",             :default => ""
      t.text     "extras"
      t.integer  "disk_pool_copies", :default => 0
      t.boolean  "guest_access",     :default => false
      t.boolean  "guest_writeable",  :default => false
      t.timestamps null: true
    end
	end
end
