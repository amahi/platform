# Amahi Home Server
# Copyright (C) 2007-2014 Amahi
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License v3
# (29 June 2007), as published in the COPYING file.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# file COPYING for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Amahi
# team at http://www.amahi.org/ under "Contact Us."

require 'fileutils'
require 'yaml'
require 'command'
require 'system_utils'

class Plugin < ApplicationRecord

	before_destroy :before_destroy

	class << self
		# installer info
		def install(installer, source)
			unpack_path = "#{HDA_TMP_DIR}/plugin"

			return nil if (installer.source_url.nil? or installer.source_url.blank?)

			plugin = nil

			FileUtils.rm_rf unpack_path
			FileUtils.mkdir_p unpack_path
			Dir.chdir(unpack_path) do
				SystemUtils.unpack(installer.source_url, source)
				files = Dir.glob '*'
				if files.size == 1
					dir = files.first
					config = YAML.load(StringIO.new(File.read "#{dir}/config/amahi-plugin.yml").read)
					plugin = dir2plugin(dir, config)
				else
					# FIXME what to do if more file are unpacked
					raise "ERROR: this plugin unpacks into more than one file!"
				end
			end
			FileUtils.rm_rf unpack_path
			plugin
		end
	end

	# uninstall when the object is destroyed
	def before_destroy
		base = File.basename path
		destination = File.join(Rails.root, "plugins", "#{1000+id}-#{base}")

		Plugin.run_migration(destination, :down)

		FileUtils.rm_rf destination
		# restart the rails stack -- FIXME: this is too much a restart would be best
		c = Command.new "touch /var/hda/platform/html/tmp/restart.txt"
		c.execute
	end

	private

	class << self
		# config is a hash containing settings from the amahi-plugin.yml file, e.g.:
		# 	{"name"=>"Foo Bar", "class"=>"FooBar", "url"=>"/tab/foo_bar"}
		def dir2plugin(source, config)
			# use the destination
			path = config["url"]
			base = File.basename path
			# create the plugin proper
			plugin = create(name: config["name"], path: path)
			destination = File.join(Rails.root, "plugins", "#{1000+plugin.id}-#{base}")
			# move the plugin files to the destination
			FileUtils.rm_rf destination
			FileUtils.mv source, destination

			self.run_migration(destination, :up)

			# restart the rails stack -- FIXME: this is too much a restart would be best
			c = Command.new "touch /var/hda/platform/html/tmp/restart.txt"
			c.execute
			# return the plugin we just created
			plugin
		end

		def run_migration(destination, type)
			migration_files = Dir["#{destination}/db/migrate/*.rb"]
			migration_files.each do |migration_file|
				start_index = migration_file.index("_")+1
				last_index = migration_file.rindex(".")-1
				require "#{migration_file}"

				class_name = migration_file[start_index..last_index].camelize.constantize
				class_name.new.migrate(type)
			end
		end

	end

end
