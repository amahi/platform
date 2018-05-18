class CreateDbs < ActiveRecord::Migration[5.1]
  def change
    create_table "dbs" do |t|
      t.string   "name",       :null => false
      t.timestamps null: true
    end
  end
end
