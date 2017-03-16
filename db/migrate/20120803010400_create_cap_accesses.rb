class CreateCapAccesses < ActiveRecord::Migration
  def change
    create_table "cap_accesses" do |t|
      t.integer  "user_id"
      t.integer  "share_id"
      t.timestamps, :null => true
    end
  end
end