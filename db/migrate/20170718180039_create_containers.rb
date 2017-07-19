class CreateContainers < ActiveRecord::Migration
  def change
    create_table :containers do |t|
      t.string :name, :null=>false
      t.string :options, :null=>false
      t.integer :app_id, :null=>false
      t.timestamps
    end

    add_foreign_key :containers, :apps
  end
end
