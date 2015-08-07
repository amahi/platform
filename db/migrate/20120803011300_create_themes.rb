class CreateThemes < ActiveRecord::Migration
	def change
		create_table "themes" do |t|
			t.string "name", :default => "", :null => false
			t.string "css",  :default => "", :null => false
		end
	end
end
