class CreateTestapps < ActiveRecord::Migration[5.0]
  def change
    create_table :testapps do |t|
      t.string :identifier
      t.text :installer
      t.text :info
      t.timestamps
    end
  end
end
