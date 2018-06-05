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

require 'command'
require 'platform'

class Webapp < ApplicationRecord

	BASE = Rails.env.production? ? "/usr/share/hda-platform/webapps/app-%s.conf" : (File.join(Rails.root, "misc/webapps/app-%s.conf"))

	belongs_to :dns_alias, :dependent => :destroy, :class_name => 'DnsAlias', optional: true
	has_many :webapp_aliases, :dependent => :destroy

	before_create :before_create_hook , :unless => :php5?
	after_destroy :after_destroy_hook
	after_save :after_save_hook, :unless => :php5?
	before_validation :create_unique_fname, :on => :create

	validates :name, :fname, :path, :presence => true

	def php5?
		self.kind == "PHP5"
	end

	def full_url
		"http://#{name}.#{Setting.value_by_name('domain')}"
	end

	def write_conf_file
		fname = TempCache.unique_filename "webapp"
		File.open(fname, "w") { |f| f.write(conf_file) }

		# move path to the http area
		c = Command.new "mv -f #{fname} /etc/httpd/conf.d/#{self.fname}"

		# reload the server
		c.execute
		Platform.reload(:apache)
	end

	def create_php5_vhost
		puts "Creating vhost for php5 #{self.id}"
		self.build_dns_alias(name: self.name)
		FileUtils.mkpath(File.join(path, "html"))
		FileUtils.mkpath(File.join(path, "logs"))
		write_conf_file
	end

	protected

	def before_create_hook
		# FIXME - a huuuuge amount of checks need to be
		# done here!
		# A very dirty hack to make php5 container app vhosts works.
		# Most likely will remove it later on.
		if self.kind!="PHP5"
			self.build_dns_alias(name: self.name)
			FileUtils.mkpath(File.join(path, "html"))
			FileUtils.mkpath(File.join(path, "logs"))
			write_conf_file
		end
	end

	def create_unique_fname
		# ok, maybe not entirely unique, but this should
		# work fine - FIXME
		self.fname = "%4d-#{self.name}.conf" % (1000 + Webapp.count)
	end

	def after_save_hook
		# FIXME - check and change name, path, etc.
		write_conf_file
	end

	def after_destroy_hook
		c = Command.new
		c.submit("rm -f /etc/httpd/conf.d/#{fname}") unless fname.blank?
		c.submit("rm -rf #{path}")
		c.execute
		Platform.reload(:apache)
	end

	def conf_file
		# clean the path first
		path.sub!(/\/+$/, '')
		path.gsub!(/\/+/, '/')
		domain = ''
		domain = (Setting.get('domain') || '') rescue ''

		self.kind = 'generic' if self.kind.nil?
		case self.kind.downcase
		when 'python'
			f = File.open(BASE % "python")
		when 'ror'
			f = File.open(BASE % "ror")
		when 'custom'
			f = File.open(BASE % "custom")
		when 'php5'
			f = File.open(BASE % "php5")
		else # generic
			f = File.open(BASE % "generic")
		end
		server_aliases = self.aliases.split(/[, ]+/).select{ |s| ! (s.empty? || DnsAlias.where(:alias=>s).first) }
		server_aliases += self.webapp_aliases.map{|wa| wa.name}
		aliases = server_aliases.count > 0 ? ("ServerAlias " + server_aliases.join(" ")) : ""
		conf = f.readlines.join
		conf = conf.gsub(/HDA_APP_NAME/, name)
		conf = conf.gsub(/APP_ROOT_DIR/, path)
		conf = conf.gsub(/HDA_DOMAIN/, domain) unless domain.empty?
		conf = conf.gsub(/HDA_AUTHFILE/, "#{path}/htpasswd")
		conf = conf.gsub(/HDA_ACCESS/, login_required ? access_conf : '')
		conf = conf.gsub(/APP_ALIASES/, aliases 	|| '')

		if self.kind=="PHP5"
			php5_app_id = App.where(webapp: self).count > 0 ? App.where(webapp: self)[0].id : 0
			if php5_app_id==0
				raise "App not created yet. Unable to assign port to container."
			end
			conf = conf.gsub(/APP_PORT/, "#{35000 + php5_app_id}")
		end

		begin
			conf = conf.gsub(/APP_CUSTOM_OPTIONS/, custom_options || '')
		rescue
			# this is to prevent migrations from
			# failing in machines that take a while
			# to upgrade
			conf = conf.gsub(/APP_CUSTOM_OPTIONS/, '')
		end
		conf
	end

	def access_conf
		["AuthUserFile /var/hda/web-apps/htpasswd",
			"AuthGroupFile /dev/null",
			"AuthName \"User Login Required for This Area\"",
			"AuthType Basic",
			"<Limit GET POST>",
			"\trequire valid-user",
		"</Limit>"].join("\n\t\t")
	end

end
