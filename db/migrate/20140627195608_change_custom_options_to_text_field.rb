class ChangeCustomOptionsToTextField < ActiveRecord::Migration
  def change
  	change_table :webapps do |t|
	  t.change :custom_options, :text, :limit => nil
	end
  end
end
