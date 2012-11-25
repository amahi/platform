class CreateFirewalls < ActiveRecord::Migration
  def change
    create_table "firewalls" do |t|
      t.string   "kind",       :default => ""
      t.boolean  "state",      :default => true
      t.string   "ip",         :default => ""
      t.string   "protocol",   :default => "both"
      t.string   "range",      :default => ""
      t.string   "mac",        :default => ""
      t.string   "url",        :default => ""
      t.string   "comment",    :default => ""
      t.timestamps
    end
  end
end
