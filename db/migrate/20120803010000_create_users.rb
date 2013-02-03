class CreateUsers < ActiveRecord::Migration
	def change
		create_table "users" do |t|
			t.string   "login",                            :null => false
			t.string   "name"
			t.string   "crypted_password"
			t.string   "password_salt"
			t.string   "persistence_token"
			t.integer  "login_count",       :default => 0, :null => false
			t.datetime "last_request_at"
			t.datetime "last_login_at"
			t.datetime "current_login_at"
			t.string   "last_login_ip"
			t.string   "current_login_ip"
			t.boolean  "admin"
			t.text     "public_key"
			t.timestamps
		end
	end
end
