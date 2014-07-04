class ChangeCustomOptionsToTextField < ActiveRecord::Migration
  def up
  	change_table :webapps do |t|
	  t.change :custom_options, :text, :default => nil
	end
  end
  def down
  	change_table :webapps do |t|
	  t.change :custom_options, :string, :default => ""
	end
  end
end
