class CreateWebappAliases < ActiveRecord::Migration[5.1]
	def change
    create_table "webapp_aliases" do |t|
      t.string   "name"
      t.integer  "webapp_id"
      t.timestamps null: true
    end
	end
end
