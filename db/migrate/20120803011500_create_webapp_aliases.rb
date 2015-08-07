class CreateWebappAliases < ActiveRecord::Migration
	def change
		create_table "webapp_aliases" do |t|
			t.string   "name"
			t.integer  "webapp_id"
			t.timestamps, null: false
		end
	end
end
