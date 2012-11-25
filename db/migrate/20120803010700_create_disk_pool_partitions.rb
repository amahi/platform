class CreateDiskPoolPartitions < ActiveRecord::Migration
	def change
    create_table "disk_pool_partitions" do |t|
      t.string   "path"
      t.integer  "minimum_free", :default => 10
      t.timestamps
    end
	end
end
