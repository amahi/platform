class CreateCapWriters < ActiveRecord::Migration
  def change
    create_table "cap_writers" do |t|
      t.integer  "user_id"
      t.integer  "share_id"
      t.timestamps null: true
    end
  end
end