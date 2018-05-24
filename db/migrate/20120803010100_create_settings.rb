class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table "settings" do |t|
      t.string "name"
      t.string "value"
      t.string "kind",  :default => "general"
    end
  end
end
