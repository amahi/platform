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

require 'strscan'
require 'command'

class User < ActiveRecord::Base

	scope :admins, where(:admin => 1)

	begin
		acts_as_authentic do |c|
			# DEBUG: only for testing
			# c.logged_in_timeout = 1.minute
		end
	rescue
		# NOTE: ignore errors - only happens when using from a
		# non-fully active record compliant, e.g. from the app installer
	end

	attr_accessible :login, :name, :password, :password_confirmation, :admin

	validates :login, :presence => true,
	:format => { :with => /^[A-Za-z][A-Za-z0-9]+$/ },
	:length => { :in => 3..32 },
	:uniqueness => { :case_sensitive => false },
	:user_not_exist_in_system => {:message => 'already exists in system', :on => :create}

	# this is a very coarse check on the public key! sshd(8) explains each key can be up to 8k?
	validates_length_of :public_key, :in => 300..8192, :allow_nil => true

	validates :name, :presence => true

	#NOTE: validation for password and password_confirmation is set by authlogic

	before_create :before_create_hook
	before_save :before_save_hook
	before_destroy :before_destroy_hook
	after_save :after_save_hook
	after_create :after_create_hook

	class << self
		def system_find_name_by_username(username)
			# return [username, 500] if Yetting.dummy_mode.inspect
			pwd = StringScanner.new(File.open('/etc/passwd').readlines.join)
			user = Regexp.new("^(#{username}):[^:]*:(\\d+):\\d+:([^:]*):", Regexp::MULTILINE | Regexp::IGNORECASE)
			pwd.scan_until user or return nil
			uid = pwd[2].to_i
			# NOTE-cpg: in some cases (ubuntu 12), the name ends up with three commas at the end for some reason
			name = pwd[3].gsub(/,*$/,'')
			[name, uid, pwd[1]]
		end

		def system_all_new_users
			res = []
			Dir.chdir("/home") do
				Dir.glob("*").sort.reverse.each do |login|
					unless User.find_by_login login
						name, uid = system_find_name_by_username login
						# FIXME-cpg: Fedora specific constant 500 here
						res << { :login => login, :name => name } unless name.nil? or name.blank? or uid < 500
					end
				end
			end
			res
		end

		def all_users
			new_users = self.system_all_new_users
			self.create(new_users) unless new_users.blank?
			self.where('login not in (?)', ['root']).sort { |x,y| x.login <=> y.login }
		end

		def system_user_exists? (username)
			system_find_name_by_username(username)
		end

		def is_valid_name? (username)
			name, uid = system_find_name_by_username(username)
			# only valid names must not exist already
			name == nil
		end
	end


	# add to the group called "users" so that it's like the rest
	def add_to_users_group
		c = Command.new("usermod -g users -a -G users \"#{self.login}\"")
		c.execute
	end

	def add_or_passwd_change_samba_user
		# adds samba user or simply chages it's password
		pwd_option = password_option()
		c = Command.new("usermod #{pwd_option} \"#{self.login}\"")
		c.execute
		unless self.password.nil? && self.password.blank?
			p = self.password
			c = Command.new "(echo '#{p}'; echo '#{p}') | pdbedit -d0 -t -a -u \"#{self.login}\""
			c.execute
		end
	end

	# needs to create authlogic records for this user
	def needs_auth?
		!crypted_password || crypted_password.blank?
	end


	protected

	def before_create_hook
		# FIXME: this is an issue with fedora 12 and usernames in lowercase
		# https://bugzilla.redhat.com/show_bug.cgi?id=550732
		# http://bugs.amahi.org/issues/show/392
		self.login = self.login.downcase
		return if User.system_user_exists? self.login
		pwd_option = password_option()
		# FIXME: use a different (programmable) group
		c = Command.new "useradd -m -g users -c \"#{self.name}\" #{pwd_option} \"#{self.login}\""
		# FIXME - we should use add_or_passwd_change_samba_user above! DRY
		unless self.password.nil? && self.password.blank?
			p = self.password
			c.submit("(echo '#{p}'; echo '#{p}') | pdbedit -d0 -t -a -u \"#{self.login}\"")
		end
		c.execute
	end

	# provide a password option with a crypted password suitable for the system
	# NOTE: it's different than the standard crypted password and salt in the user model!
	def password_option
		return "" if self.password.nil? || self.password.blank?
		salt = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + ['.', '/']
		salt = (salt.sort_by{rand}.join)[0,2]
		sys_crypted_password = password.crypt(salt)
		"-p \"#{sys_crypted_password}\""
	end

	def before_save_hook
		return unless User.system_user_exists? self.login
		pwd_option = password_option()
		c = Command.new("usermod -c \"#{self.name}\" #{pwd_option} \"#{self.login}\"")
		c.execute
	end

	def after_save_hook
		if admin_changed?
			make_admin
			Share.push_shares
		end
		if public_key_changed?
			update_pubkey
		end
	end

	def after_create_hook
		Share.create_logon_script(self.login)
	end

	def before_destroy_hook
		c = Command.new("pdbedit -d0 -x -u \"#{self.login}\"")
		c.submit("userdel -r \"#{self.login}\"")
		c.execute
	end

	def update_pubkey
		Platform.update_user_pubkey(login, public_key)
	end

	def make_admin
		Platform.make_admin(login, admin?)
	end
end
