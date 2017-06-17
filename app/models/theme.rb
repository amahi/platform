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

class Theme < ApplicationRecord

	def self.available
		tl = all
		Dir.chdir(File.join(Rails.root, THEME_ROOT)) do
			Dir.glob("*").sort.each do |theme_dir|
				next if where(:css=>theme_dir).first
				theme_init_file = File.join(theme_dir, "init.rb")
				if File.exist? theme_init_file
					load theme_init_file
					if defined?(theme_init) == "method"
						begin
							theme = theme_init
							tl << Theme.new(:name => theme[:name], :css => theme_dir)
						rescue => e
							# there were issues in the theme init file!!
							logger.error("=================== Amahi Theme Error BEGIN ===========================")
							logger.error(e)
							logger.error("=================== Amahi Theme Error END   ===========================")
						end
					end
				end
			end
		end
		tl
	end

	def self.dir2theme(dir)
		theme = nil
		Dir.chdir(File.join(Rails.root, THEME_ROOT)) do
			theme_init_file = File.join(dir, "init.rb")
			if File.exist? theme_init_file
				load theme_init_file
				if defined?(theme_init) == "method"
					begin
						ti = theme_init
						theme = Theme.new(:name => ti[:name], :css => dir)
					rescue => e
						# there were issues in the theme init file!!
						raise "There were issues loading file '#{theme_init_file}'"
					end
				end
			else
				raise "That file '#{theme_init_file}' does not exist!"
			end
		end
		theme.save! if theme
		theme
	end
	Theme.add_observer ThemeObserver.instance
end
