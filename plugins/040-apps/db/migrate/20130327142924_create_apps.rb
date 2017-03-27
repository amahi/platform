class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|

      t.timestamps null: true
    end
  end
end
