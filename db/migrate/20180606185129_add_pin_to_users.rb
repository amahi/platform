class AddPinToUsers < ActiveRecord::Migration[5.2]
  def change
  	add_column :users, :pin, :text, null: true
  end
end
