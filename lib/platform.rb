# Amahi Home Server
# Copyright (C) 2007-2011 Amahi
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

require 'downloader'

class Platform

	# upstart conf file for an ubuntu system
	UPSTART_CONF = "/etc/init/%s.conf"

	# legacy fallback
	LEGACY_INIT_PATH = "/etc/init.d"

	# default group for users (may change for each platform one day?)
	DEFAULT_GROUP = "users"

	PLATFORMS=['fedora', 'centos', 'ubuntu', 'debian', 'mac']
	SERVICES={
		'fedora' => {
			:apache => 'httpd',
			:dhcp => 'dhcpd',
			:named => 'named',
			:smb => 'smb',
			:nmb => 'nmb',
			:mysql => 'mysqld',
		},
		'centos' => {
			:apache => 'httpd',
			:dhcp => 'dhcpd',
			:named => 'named',
			:smb => 'smb',
			:nmb => 'nmb',
			:mysql => 'mysqld',
		},
		'ubuntu' => {
			:apache => 'apache2',
			:dhcp => 'isc-dhcp-server',
			:named => 'bind9',
			:smb => 'smbd',
			:nmb => 'nmbd',
			:mysql => 'mysql',
		},
		'debian' => {
			:apache => 'apache2',
			:dhcp => 'isc-dhcp-server',
			:named => 'bind9',
			:smb => 'samba',
			:nmb => 'samba',
			:mysql => 'mysql',
		},
		'mac' => {
			:apache => 'apache2',
			:dhcp => 'notsure', # FIXME
			:named => 'notsure', # FIXME
			:smb => 'smbd',
			:nmb => 'nmbd',
		}
	}

	FILENAMES={
		'fedora' => {
			:apache_pid => 'httpd/httpd.pid',
			:dhcpleasefile => '/var/lib/dhcpd/dhcpd.leases',
			:samba_pid => 'smbd.pid',
			:dhcpd_pid => 'dhcpd.pid',
			:monit_dir => '/etc/monit.d',
			:monit_conf => '/etc/monit.conf',
			:monit_log => '/var/log/monit',
			:syslog => '/var/log/messages',
		},
		'ubuntu' => {
			:apache_pid => 'apache2.pid',
			:dhcpleasefile => '/var/lib/dhcp3/dhcpd.leases',
			:samba_pid => 'samba/smbd.pid',
			:dhcpd_pid => 'dhcp-server/dhcpd.pid',
			:monit_dir => '/etc/monit/conf.d',
			:monit_conf => '/etc/monit/monitrc',
			:monit_log => '/var/log/monit.log',
			:syslog => '/var/log/syslog',
		},
		'debian' => {
			:apache_pid => 'apache2.pid',
			:dhcpleasefile => '/var/lib/dhcp/dhcpd.leases',
			:samba_pid => 'samba/smbd.pid',
			:dhcpd_pid => 'dhcp-server/dhcpd.pid',
			:monit_dir => '/etc/monit/conf.d',
			:monit_conf => '/etc/monit/monitrc',
			:monit_log => '/var/log/monit.log',
			:syslog => '/var/log/syslog',
		},
		'centos' => {
			:apache_pid => 'httpd/httpd.pid',
			:dhcpleasefile => '/var/lib/dhcpd/dhcpd.leases',
			:samba_pid => 'smbd.pid',
			:dhcpd_pid => nil,
			:monit_dir => '/etc/monit.d',
			:monit_conf => '/etc/monit.conf',
			:monit_log => '/var/log/monit',
			:syslog => '/var/log/messages',
		},
		'mac' => {
			:apache_pid => 'apache2.pid', # not sure; best guess; FIXME
			:dhcpleasefile => 'notsure', # FIXME
			:samba_pid => 'samba/smbd.pid',
			:dhcpd_pid => 'junk',
			:monit_conf => 'junk',
			:monit_dir => 'junk',
			:monit_log => 'junk',
			:syslog => '/var/log/system.log',
		}
	}

	def self.reload(service)
		c = Command.new("sleep 1")
		c.submit("service #{service2name service} reload")
		c.submit("sleep 1")
		c.execute
	end

	# serve file paths specific to the platform service is a symbol
	def self.file_name(service)
		file2name(service)
	end

	def self.service_name(service)
		service2name(service)
	end

	def self.platform
		@@platform
	end

	def self.fedora?
		@@platform == 'fedora'
	end

	def self.centos?
		@@platform == 'centos'
	end

	def self.ubuntu?
		@@platform == 'ubuntu'
	end

	def self.debian?
		@@platform == 'debian'
	end

	def self.install(pkgs, sha1 = nil)
		pkginstall(pkgs, sha1)
	end

	def self.uninstall(pkgs)
		pkguninstall(pkgs)
	end

	def self.service_start_command(name)
		service = service_name(name)
		if fedora?
			"systemctl start #{service}.service"
		elsif ubuntu? and File.exist?(UPSTART_CONF % service)
			"/sbin/initctl start #{service}"
		else
			# legacy fallback
			tmp = service + " start"
			(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
		end
	end

	def self.service_stop_command(name)
		service = service_name(name)
		if fedora?
			"systemctl stop #{service}.service"
		elsif ubuntu? and File.exist?(UPSTART_CONF % service)
			"/sbin/initctl stop #{service}"
		else
			# legacy fallback
			tmp = service + " stop"
			(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
		end
	end

	# watchdog restart command
	def self.watchdog_restart_command
		if fedora?
			"service monit condrestart"
		else
			# FIXME - this will restart it forcefully, even if not running
			"service monit stop; service monit start"
		end
	end

	# make a user admin -- sudo capable
	def self.make_admin(username, is_admin)
		# NOTE-cpg: tested on Fedora only
		admin_groups = is_admin ? ",wheel" : ''
		c = Command.new
		c.submit("usermod -G #{DEFAULT_GROUP}#{admin_groups} #{username}")
		c.execute
	end

	# update the public key for the user
	def self.update_user_pubkey(username, key)
		# NOTE-cpg: tested on Fedora only
		home = "/home/#{username}"
		c = Command.new
		c.submit("mkdir -p #{home}/.ssh/")
		# if the key is nil (allowed), empty the file
		c.submit("echo \"#{key || ''}\" > #{home}/.ssh/authorized_keys")
		c.submit("chown -R #{username}:#{DEFAULT_GROUP} #{home}/.ssh")
		c.submit("chmod u+rwx,go-rwx #{home}/.ssh")
		c.submit("chmod u+rw,go-rwx #{home}/.ssh/authorized_keys")
		c.execute
	end

private

	def self.set_platform
		if File.exist?('/etc/issue')
			line = nil
			File.open("/etc/issue", "r") do |issue|
				line = issue.gets
			end
			@@platform = "debian" if line.include?("Debian")
			@@platform = "ubuntu" if line.include?("Ubuntu")
			@@platform = "fedora" if line.include?("Fedora")
			@@platform = "centos" if line.include?("CentOS")
		elsif File.exist?('/mach_kernel')
			@@platform = "mac"
		else
			@@platform = nil
		end
		raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
	end

	def self.service2name(service)
		name = SERVICES[@@platform][service.to_sym]
		name || service
	end

	def self.file2name(fname)
		name = FILENAMES[@@platform][fname]
		raise "unknown filename '#{fname}' for '#{@@platform}'" unless name
		name
	end

	def self.pkginstall(pkgs, sha1 = nil)
		if debian? or ubuntu?
	                c = Command.new "DEBIAN_FRONTEND=noninteractive apt-get -y install #{pkgs}"
			c.run_now
		elsif fedora? or centos?
			if pkgs =~ /^\w+:\/\//
				# downloadable RPM
				# FIXME - check the sha1sum
				fname = Downloader.download_and_check_sha1(pkgs, sha1)
				cmd = "rpm -Uvh #{fname}"
			else
				cmd = "yum -y install #{pkgs}"
			end
			c = Command.new cmd
			c.run_now

		else
			raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
		end
	end

	def self.pkguninstall(pkgs)
		if debian? or ubuntu?
	                c = Command.new "DEBIAN_FRONTEND=noninteractive apt-get -y remove #{pkgs}"
			c.run_now
		elsif fedora? or centos?
			if pkgs =~ /^\w+:\/\/.*\/([^\/]*)\.rpm/
				cmd = "rpm -e #{$1}"
			else
				cmd = "rpm -e #{pkgs}"
			end
			c = Command.new cmd
			c.run_now
		else
			raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
		end
	end

	# class initialization
	set_platform

end
