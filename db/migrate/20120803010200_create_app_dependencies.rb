class CreateAppDependencies < ActiveRecord::Migration[5.1]
	def change
    create_table "app_dependencies" do |t|
      t.integer  "app_id"
      t.integer  "dependency_id"
      t.timestamps null: true
    end
	end
end
