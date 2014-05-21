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

class SetTheme

	attr_accessor :name, :headers, :gruff, :author, :author_url, :disable_inheritance, :path

	class << self

		def find
			begin
				theme_setting = Setting.where(:name => 'theme').first_or_create
				path = theme_setting.value
				theme_path = init_file_exists?(path) ? path : self.default
				theme = init(theme_path)
				self.new(theme.merge(:path => theme_path))
			rescue => e
				Rails.logger.error("THEME: name: #{theme_path};  error: #{e}") && exit
			end
		end

		def init(path)
			load init_file_path(path)
			theme_init if defined?(theme_init) == "method"
		end

		def init_file_path(path)
			"#{Rails.root}/#{THEME_ROOT}/#{path}/init.rb"
		end

		def init_file_exists?(path)
			File.exist?(init_file_path(path))
		end

		def default
			Yetting.default_theme
		end
	end

	def initialize(theme={})
		self.path = theme[:path]
		self.name = theme[:name]
		self.headers = theme[:headers].present? ? theme[:headers].map{|h| (h =~ /\.js$/) ? "/#{THEME_ROOT}/#{@theme_name}/#{h}" : h } : []
		self.gruff = theme[:gruff_theme]
		self.author = theme[:author_name]
		self.author_url = theme[:author_url]
		self.disable_inheritance = theme[:disable_inheritance]
	end

	def default
		self.class.default
	end

	def default?
		path == default
	end

	def not_default_and_not_disable_inheritance?
		!default? && !disable_inheritance
	end

end
