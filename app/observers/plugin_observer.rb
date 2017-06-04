class PluginObserver < ActiveRecord::Observer

  # uninstall when the object is destroyed
  def before_destroy(plugin)
		base = File.basename plugin.path
		location = File.join(Rails.root, "plugins", "#{1000+plugin.id}-#{base}")
		array = []
		array <<"#{location}/db/migrate"
		puts "Reverting the changes to the database made by the plugin"
		ActiveRecord::Migrator.down(array,nil)
		FileUtils.rm_rf location
		# restart the rails stack -- FIXME: this is too much a restart would be best
		c = Command.new "touch /var/hda/platform/html/tmp/restart.txt"
		c.execute
	end

end
