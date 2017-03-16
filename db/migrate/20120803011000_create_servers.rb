class CreateServers < ActiveRecord::Migration
	def change
    create_table "servers" do |t|
      t.string   "name",                            :null => false
      t.string   "comment",       :default => ""
      t.string   "pidfile"
      t.string   "start"
      t.string   "stop"
      t.boolean  "monitored",     :default => true
      t.boolean  "start_at_boot", :default => true
      t.timestamps, :null => true
    end
	end
end
