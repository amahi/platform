# Amahi Home Server
# Copyright (C) 2007-2013 Amahi
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

class Db < ActiveRecord::Base

	DB_BACKUPS_DIR = "/var/hda/dbs"

	after_create :after_create_hook
	after_destroy :after_destroy_hook

  attr_accessible :name

	# stubs for name, password and hostname, in case they need changed later

	def username
		name
	end

	def password
		name
	end

	def hostname
		"localhost"
	end

private

	def after_create_hook
		c = self.class.connection
		password = name
		user = name
		host = 'localhost'
		c.execute "CREATE DATABASE IF NOT EXISTS `#{name}` DEFAULT CHARACTER SET utf8;"
		# FIXME - why do we have to drop the user first in some cases?!?!!??
		c.execute("DROP USER '#{user}'@'#{host}';") rescue nil
		c.execute "CREATE USER '#{user}'@'#{host}' IDENTIFIED BY '#{password}';"
		c.execute "GRANT ALL PRIVILEGES ON `#{name}`.* TO '#{user}'@'#{host}';"
	end

	def after_destroy_hook
		user = name
		filename = Time.now.strftime("#{DB_BACKUPS_DIR}/%y%m%d-%H%M%S-#{name}.sql.bz2")
		system("mysqldump --add-drop-table -u#{user} -p#{user} #{name} | bzip2 > #{filename}")
		Dir.chdir(DB_BACKUPS_DIR) do
			system("ln -sf #{filename} latest-#{name}.bz2")
		end
		c = self.class.connection
		host = 'localhost'
		c.execute "drop user '#{user}'@'#{host}';"
		c.execute "drop database if exists `#{name}`;"
	end
end
