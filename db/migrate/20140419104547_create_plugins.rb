class CreatePlugins < ActiveRecord::Migration
	def change
		create_table :plugins do |t|
			t.string :name
			t.string :path
			t.timestamps null: true
		end
		add_column :apps, :plugin_id, :integer
	end
end
