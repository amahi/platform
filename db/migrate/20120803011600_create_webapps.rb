class CreateWebapps < ActiveRecord::Migration
	def change
		create_table "webapps" do |t|
			t.string   "name",                              :null => false
			t.string   "path",           :default => ""
			t.string   "kind",           :default => ""
			t.string   "aliases",        :default => ""
			t.string   "fname",          :default => ""
			t.boolean  "deletable",      :default => true
			t.boolean  "login_required", :default => false
			t.integer  "dns_alias_id"
			t.string   "custom_options", :default => ""
			t.timestamps null: false
		end
	end
end
