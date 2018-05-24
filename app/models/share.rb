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
require 'temp_cache'

class Share < ApplicationRecord

	DEFAULT_SHARES_ROOT = '/var/hda/files'

	SIGNATURE = "Amahi configuration"
	DEFAULT_SHARES = [ "Books", "Pictures", "Movies", "Videos", "Music", "Docs", "Public", "TV" ].each {|s| I18n.t s }
	PDC_SETTINGS = "/var/hda/domain-settings"

	default_scope {order("name")}
	# scope :in_disk_pool, where([ "disk_pool_copies > ?", 0])

	has_many :cap_accesses, :dependent => :destroy
	has_many :users_with_share_access, :through => :cap_accesses, :source => :user

	has_many :cap_writers, :dependent => :destroy
	has_many :users_with_write_access, :through => :cap_writers, :source => :user

	before_save :before_save_hook
	before_destroy :before_destroy_hook
	after_save :after_save_hook
	after_destroy :after_destroy_hook

	validates :name, presence: true,
		format: { :with => /\A\S[\S ]+\z/ },
		length: 1..32,
		uniqueness: { :case_sensitive => false }

	validates :path, presence: true,
		length: 2..64

	# return the full path of a share (even if it does not exist!).
	# (this is for encapsulation purposes mostly)
	def self.default_full_path(name)
		File.join(DEFAULT_SHARES_ROOT, name.downcase)
	end

	# save the samba config file
	def self.push_shares
		domain = Setting.value_by_name "domain"
		debug = Setting.shares.value_by_name('debug') == '1'

		smbconf = TempCache.unique_filename "smbconf"
		File.open(smbconf, "w") do |l|
			l.write(self.samba_conf(domain))
		end

		lmhosts = TempCache.unique_filename "lmhosts"
		File.open(lmhosts, "w") do |l|
			l.write(self.samba_lmhosts(domain))
		end

		# copy files to the samba area
		time = Time.now
		c = Command.new
		c.submit("cp /etc/samba/smb.conf \"/tmp/smb.conf.#{time}\"") if debug
		c.submit("cp #{smbconf} /etc/samba/smb.conf")
		c.submit("rm -f #{smbconf}")

		c.submit("cp /etc/samba/lmhosts \"/tmp/lmhosts.#{time}\"") if debug
		c.submit("cp #{lmhosts} /etc/samba/lmhosts")
		c.submit("rm -f #{lmhosts}")

		c.execute

		# reload the server - nmbd will do it on it's own!
		Platform.reload(:nmb)
	end

	def self.create_default_shares
		DEFAULT_SHARES.each do |s|
			sh = Share.new
			sh.path = Share.default_full_path(s)
			sh.name = s
			sh.rdonly = false
			sh.visible = true
			sh.tags = s.downcase
			sh.extras = ""
			sh.disk_pool_copies = 0
			sh.save!
		end
	end

	# configuration for one share
	def share_conf
		ret = "[%s]\n"		\
		"\tcomment = %s\n" 	\
		"\tpath = %s\n" 	\
		"\twriteable = %s\n" 	\
		"\tbrowseable = %s\n%s%s%s%s\n"
		wr = rdonly ? "no" : "yes"
		br = visible ? "yes" : "no"
		allowed  = ''
		writes  = ''
		masks = "\tcreate mask = 0775\n"
		masks += "\tforce create mode = 0664\n"
		masks += "\tdirectory mask = 0775\n"
		masks += "\tforce directory mode = 0775\n"
		unless everyone
			allowed = "\tvalid users = "
			writes = "\twrite list = "
			u = users_with_share_access.map{ |acc| acc.login } rescue nil
			w = users_with_write_access.select{ |wrt| u.include?(wrt.login) }.map{ |user| user.login } rescue nil
			u = ['nobody'] if !u or u.empty?
			u |= ['nobody'] if guest_access
			allowed += u.join(', ') + "\n"
			w = ['nobody'] if !w or w.empty?
			w |= ['nobody'] if guest_writeable
			writes += w.join(', ') + "\n"
		end
		if (guest_access || guest_writeable) && !everyone
			writes += "\tguest ok = yes\n"
		end
		e = ""
		e = "\t" + (extras.gsub /\n/, "\n\t") unless extras.nil?
		if disk_pool_copies > 0
			tmp = e.gsub /\tdfree command.*\n/, ''
			e = tmp.gsub /\tvfs objects.*greyhole.*\n/, ''
			e += "\n\t" + 'dfree command = /usr/bin/greyhole-dfree' + "\n"
			e += "\t" + 'vfs objects = greyhole' + "\n"
		end
		ret % [name, name, path, wr, br, allowed, writes, masks, e]
	end

	def tag_list
		parse_tags tags
	end

	def self.basenames
		all.map { |s| [s.path, s.name] }
	end

	def make_guest_writeable
		c = Command.new
		c.submit("chmod o+w \"#{self.path}\"")
		c.execute
	end

	def make_guest_non_writeable
		c = Command.new
		c.submit("chmod o-w \"#{self.path}\"")
		c.execute
	end

	def toggle_everyone!
		if self.everyone
			users = User.all
			self.users_with_share_access = users
			self.users_with_write_access = users
			self.everyone = false
			self.rdonly = true
		else
			self.users_with_share_access = []
			self.users_with_write_access = []
			self.guest_access = false
			self.guest_writeable = false
			self.everyone = true
		end
		self.save
	end

	def toggle_visible!
		self.visible = !self.visible
		self.save
	end

	def toggle_readonly!
		self.rdonly = !self.rdonly
		self.save
	end

	def toggle_access!(user_id)
		unless self.everyone
			user = User.find(user_id)
			if self.users_with_share_access.include? user
				self.users_with_share_access -= [user]
			else
				self.users_with_share_access += [user]
			end
		end
		self.save
	end

	def toggle_write!(user_id)
		unless self.everyone
			user = User.find(user_id)
			if self.users_with_write_access.include? user
				self.users_with_write_access -= [user]
			else
				self.users_with_write_access += [user]
			end
		end
		self.save
	end

	def toggle_guest_access!
		if self.guest_access
			self.guest_access = false
		else
			self.guest_access = true
			# forced read-only as default
			self.guest_writeable = false
		end
		self.save
	end

	def toggle_guest_writeable!
		self.guest_writeable = !self.guest_writeable
		self.save
	end

	def update_tags!(params)
		# format with coma is set in before save

		unless params[:path].blank?
			self.update_attributes(params)
		else
			name = params[:name].downcase
			if self.tags.include?(name)
				self.tags = self.tags.gsub(name, '')
			else
				self.tags = "#{self.tags}, #{name}"
			end
			self.save
		end

	end

	def toggle_disk_pool!
		self.disk_pool_copies = (self.disk_pool_copies > 0) ? 0 : 1
		self.save
	end

	def update_extras!(params)
		self.update_attributes(params)
	end

	# make all the files in the share globally writeable
	def clear_permissions
		c = Command.new
		c.submit("chmod -R a+rwx \"#{self.path}\"")
		c.execute
	end

	private

	def before_save_hook
		self.tags = self.tags.split(/\s*,\s*|\s+/).reject {|s| s.empty? }.join(', ').downcase if self.tags_changed?
		return unless self.path_changed?
		return if self.path.nil? or self.path.blank?
		user = User.admins.first.login
		c = Command.new
		c.submit("rmdir \"#{self.path_was}\"") unless self.path_was.blank?
		c.submit("mkdir -p \"#{self.path}\"")
		c.submit("chown #{user}:users \"#{self.path}\"")
		c.submit("chmod g+w \"#{self.path}\"")
		c.execute
	end

	def after_save_hook
		if guest_writeable_changed?
			guest_writeable ? make_guest_writeable : make_guest_non_writeable
		end
		if everyone
			users = User.all
			self.users_with_share_access = users
			self.users_with_write_access = users
		end
		Share.push_shares
	end

	def before_destroy_hook
		c = Command.new("rmdir --ignore-fail-on-non-empty \"#{self.path}\"")
		c.execute
	end

	def after_destroy_hook
		Share.push_shares
	end

	def self.samba_conf(domain)
		ret = self.header(domain)
		Share.all.each do |s|
			ret += s.share_conf
		end
		ret
	end

	def self.header_workgroup(domain)
		short_domain = Setting.find_or_create_by(Setting::GENERAL, 'workgroup', 'WORKGROUP').value
		debug = Setting.shares.value_by_name('debug') == '1'
		win98 = Setting.shares.value_by_name('win98') == '1'
		ret = ["# This file is automatically generated for WORKGROUP setup.",
			"# Any manual changes MAY BE OVERWRITTEN\n# #{SIGNATURE}, generated on #{Time.now}",
			"[global]",
			"\tworkgroup = %s",
			"\tserver string = %s",
			"\tnetbios name = hda",
			"\tprinting = cups",
			"\tprintcap name = cups",
			"\tload printers = yes",
			"\tcups options = raw",
			"\tlog file = /var/log/samba/%%m.log",
			"\tlog level = #{debug ? 5 : 0}",
			"\tmax log size = 150",
			"\tpreferred master = yes",
			"\tos level = 60",
			"\ttime server = yes",
			"\tunix extensions = no",
			"\twide links = yes",
			"\tsecurity = user",
			"\tusername map script = /usr/share/hda-platform/hda-usermap",
			"\tlarge readwrite = yes",
			"\tencrypt passwords = yes",
			"\tdos charset = CP850",
			"\tunix charset = UTF8",
			"\tguest account = nobody",
			"\tmap to guest = Bad User",
			"\twins support = yes",
			win98 ? "client lanman auth = yes" : "",
			"",
			"[homes]",
			"\tcomment = Home Directories",
			"\tvalid users = %%S",
			"\tbrowseable = no",
			"\twritable = yes",
			"\tcreate mask = 0644",
		"\tdirectory mask = 0755"].join "\n"
		ret % [short_domain, domain]
	end

	def self.header_pdc(domain)
		short_domain = Setting.shares.value_by_name("workgroup") || 'workgroup'
		debug = Setting.shares.value_by_name('debug') == '1'
		admins = User.admins rescue ["no_such_user"]
		ret = ["# This file is automatically generated for PDC setup.",
			"# Any manual changes MAY BE OVERWRITTEN\n# #{SIGNATURE}, generated on #{Time.now}",
			"[global]",
			"\tworkgroup = %s",
			"\tserver string = %s",
			"\tnetbios name = hda",
			"\tprinting = cups",
			"\tprintcap name = cups",
			"\tload printers = yes",
			"\tcups options = raw",
			"\tlog file = /var/log/samba/%%m.log",
			"\tlog level = #{debug ? 5 : 0}",
			"\tmax log size = 150",
			"\tpreferred master = yes",
			"\tos level = 65",
			"\tdomain master = yes",
			"\tlocal master = yes",
			"\tadmin users = #{admins.map{|u| u.login}.join ', '}",
			"\tdomain logons = yes",
			"\tlogon path = \\\\%%L\\profiles\\%%U",
			"\tlogon drive = q:",
			"\tlogon home = \\\\%%N\\%%U",
			"\ttime server = yes",
			"\tunix extensions = no",
			"\twide links = yes",
			"\tsecurity = user",
			"\tusername map script = /usr/share/hda-platform/hda-usermap ",
			"\tlarge readwrite = yes",
			"\tencrypt passwords = yes",
			"\tdos charset = CP850",
			"\tunix charset = UTF8",
			"\tguest account = nobody",
			"\tmap to guest = Bad User",
			"\twins support = yes",
			"\tlogon script = %%U.bat",
			"\t# FIXME - is 99 (nobody) the right group?",
			"\tadd machine script = /usr/sbin/useradd -d /dev/null -g 99 -s /bin/false -M %%u",
			"",
			"[netlogon]",
			"\tpath = #{PDC_SETTINGS}/netlogon",
			"\tguest ok = yes",
			"\twritable = no",
			"\tshare modes = no",
			"",
			"[profiles]",
			"\tpath = #{PDC_SETTINGS}/profiles",
			"\twritable = yes",
			"\tbrowseable = no",
			"\tread only = no",
			"\tcreate mode = 0777",
			"\tdirectory mode = 0777",
			"",
			"[homes]",
			"\tcomment = Home Directories",
			"\tread only = no",
			"\twriteable = yes",
			"\tbrowseable = yes",
			"\tcreate mask = 0640",
			"\tdirectory mask = 0750",
		"\n"].join "\n"
		ret % [short_domain, domain]
	end

	def self.header_common
		["",
			"[print$]",
			"\tpath = /var/lib/samba/drivers",
			"\tread only = yes",
			"\tforce group = root",
			"\twrite list = @ntadmin root",
			"\tforce group = root",
			"\tcreate mask = 0664",
			"\tdirectory mask = 0775",
			"\tguest ok = yes",
			"",
			"[printers]",
			"\tpath = /var/spool/samba",
			"\twriteable = yes",
			"\tbrowseable = yes",
			"\tprintable = yes",
		"\tpublic = yes\n\n"].join("\n")
	end

	def self.header(domain)
		pdc = Setting.shares.value_by_name('pdc') == '1'
		h = pdc ? header_pdc(domain) : header_workgroup(domain)
		h + "\n" + self.header_common
	end

	def self.create_logon_script(username)
		# do nothing for PDC
		pdc = Setting.shares.value_by_name('pdc') == '1'
		return unless pdc
		return if File.exists?("#{PDC_SETTINGS}/netlogon/#{username}.bat")
		open("#{PDC_SETTINGS}/netlogon/#{username}.bat", "w", 0644) do |f|
			f.puts "REM Initial content generated by Amahi on #{Time.now}"
			f.puts "REM can be safely customized by Admin"
			f.puts "logon.bat"
		end
	end

	def self.samba_lmhosts(domain)
		ip = "#{Setting.value_by_name('net')}.#{Setting.value_by_name('self-address')}"
		ret = ["# This file is automatically generated. Any manual changes MAY BE OVERWRITTEN\n# #{SIGNATURE}, generated on #{Time.now}",
			"127.0.0.1 localhost",
			"%s hda",
			"%s files",
			"%s hda.%s",
		"%s files.%s"].join "\n"
		ret % [ip, ip, ip, domain, ip, domain]
	end

	def self.default_samba_domain(domain)
		d = domain.gsub /\.(com|net|org|local|co.uk|mobi|pro|info|asia|biz|..)$/, ''
		d = d.gsub /\./, '_'
		# fallback, in case too much gets chopped
		d = domain if d.size == 0
		d = d[-15..-1] if d.size > 15
		d
	end
end
