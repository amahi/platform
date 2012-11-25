class CreateWebappAliases < ActiveRecord::Migration
	def change
    create_table "webapp_aliases" do |t|
      t.string   "name"
      t.integer  "webapp_id"
      t.timestamps
    end
	end
end
