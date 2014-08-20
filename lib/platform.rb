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

	# Using DNSMASQ
	DNSMASQ = true

	def self.dnsmasq?
		DNSMASQ ? true : false
	end

	PLATFORMS=['fedora', 'centos', 'ubuntu', 'debian', 'mac', 'mint', 'arch']

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
		},
		'mint' => {
			:apache => 'apache2',
			:dhcp => 'isc-dhcp-server',
			:named => 'bind9',
			:smb => 'smbd',
			:nmb => 'nmbd',
			:mysql => 'mysql',
		},
		'arch'   => {
			:apache => 'httpd',
			:dhcp => 'dhcpd',
			:named => 'named',
			:smb => 'smbd',
			:nmb => 'nmbd',
			:mysql => 'mysqld',
		}
	}
	FILENAMES={
		'fedora' => {
			:apache_pid => 'httpd/httpd.pid',
			:dhcpleasefile => dnsmasq? ? '/var/lib/dnsmasq/dnsmasq.leases' : '/var/lib/dhcpd/dhcpd.leases',
			:samba_pid => 'smbd.pid',
			:dhcpd_pid => 'dhcpd.pid',
			:monit_dir => '/etc/monit.d',
			:monit_conf => '/etc/monit.conf',
			:monit_log => '/var/log/monit',
			:syslog => '/var/log/messages',
		},
		'ubuntu' => {
			:apache_pid => 'apache2.pid',
			:dhcpleasefile => dnsmasq? ? '/var/lib/dnsmasq/dnsmasq.leases' : '/var/lib/dhcp3/dhcpd.leases',
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
			:dhcpleasefile => dnsmasq? ? '/var/lib/dnsmasq/dnsmasq.leases' : '/var/lib/dhcpd/dhcpd.leases',
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
		},
		'mint' => {
			:apache_pid => 'apache2.pid',
			:dhcpleasefile => dnsmasq? ? '/var/lib/dnsmasq/dnsmasq.leases' : '/var/lib/dhcp3/dhcpd.leases',
			:samba_pid => 'samba/smbd.pid',
			:dhcpd_pid => 'dhcp-server/dhcpd.pid',
			:monit_dir => '/etc/monit/conf.d',
			:monit_conf => '/etc/monit/monitrc',
			:monit_log => '/var/log/monit.log',
			:syslog => '/var/log/syslog',
		},
		'arch' => {
			:apache_pid => 'httpd/httpd.pid',
			:dhcpleasefile => dnsmasq? ? '/var/lib/dnsmasq/dnsmasq.leases' : '/var/lib/dhcpd/dhcpd.leases',
			:samba_pid => 'smbd.pid',
			:dhcpd_pid => 'dhcpcd.pid',
			:monit_dir => '/etc/monit.d',
			:monit_conf => '/etc/monit.conf',
			:monit_log => '/var/log/monit',
			:syslog => '/var/log/messages',
		}
	}
	class << self
		def reload(service)
			c = Command.new("sleep 1")
			c.submit("service #{service2name service} reload")
			c.submit("sleep 1")
			c.execute
		end

		# serve file paths specific to the platform service is a symbol
		def file_name(service)
			file2name(service)
		end

		def service_name(service)
			service2name(service)
		end

		def platform
			@@platform
		end

		def arch?
			@@platform == 'arch'
		end

		def fedora?
			@@platform == 'fedora'
		end

		def centos?
			@@platform == 'centos'
		end

		def ubuntu?
			@@platform == 'ubuntu'
		end

		def debian?
			@@platform == 'debian'
		end

		def mint?
			@@platform == 'mint'
		end

		def mac?
			@@platform == 'mac'
		end

		def install(pkgs, sha1 = nil)
			pkginstall(pkgs, sha1)
		end

		def uninstall(pkgs)
			pkguninstall(pkgs)
		end

		def service_start_command(name)
			service = service_name(name)
			if fedora? or arch?
				"/usr/bin/systemctl start #{service}.service"
			elsif ubuntu? and File.exist?(UPSTART_CONF % service)
				"/sbin/initctl start #{service}"
			else
				# legacy fallback
				tmp = service + " start"
				(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
			end
		end

		def service_stop_command(name)
			service = service_name(name)
			if fedora? or arch?
				"/usr/bin/systemctl stop #{service}.service"
			elsif ubuntu? and File.exist?(UPSTART_CONF % service)
				"/sbin/initctl stop #{service}"
			else
				# legacy fallback
				tmp = service + " stop"
				(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
			end
		end

		def service_enable_command(name)
			service = service_name(name)
			if fedora? or arch?
				"/usr/bin/systemctl enable #{service}.service"
			elsif ubuntu? and File.exist?(UPSTART_CONF % service)
				"/sbin/initctl enable #{service}"
			else
				# legacy fallback
				tmp = service + " enable"
				(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
			end
		end

		def service_disable_command(name)
			service = service_name(name)
			if fedora? or arch?
				"/usr/bin/systemctl enable #{service}.service"
			elsif ubuntu? and File.exist?(UPSTART_CONF % service)
				"/sbin/initctl disable #{service}"
			else
				# legacy fallback
				tmp = service + " disable"
				(tmp =~ /^\//) ? tmp : File.join(LEGACY_INIT_PATH, tmp)
			end
		end

		# watchdog restart command
		def watchdog_restart_command
			if fedora?
				"service monit condrestart"
			else
				# FIXME - this will restart it forcefully, even if not running
				"service monit stop; service monit start"
			end
		end

		# make a user admin -- sudo capable
		def make_admin(username, is_admin)
			# WARNING-cpg: tested on Fedora only
			admin_groups = is_admin ? ",wheel" : ''
			c = Command.new
			c.submit("usermod -G #{DEFAULT_GROUP}#{admin_groups} #{username}")
			c.execute
		end

		# update the public key for the user
		def update_user_pubkey(username, key)
			# WARNING-cpg: tested on Fedora only
			fname = TempCache.unique_filename "key"
			File.open(fname, "w") { |f| f.write(key) }
			home = "/home/#{username}"
			c = Command.new
			c.submit("mkdir -p #{home}/.ssh/")
			# if the key is nil (allowed), empty the file
			c.submit("mv #{fname} #{home}/.ssh/authorized_keys")
			c.submit("chown -R #{username}:#{DEFAULT_GROUP} #{home}/.ssh")
			c.submit("chmod u+rwx,go-rwx #{home}/.ssh")
			c.submit("chmod u+rw,go-rwx #{home}/.ssh/authorized_keys")
			c.execute
		end

		def platform_versions
			platform = ""
			hda_ctl = ""
			if fedora?
				open("|rpm -q hda-platform hda-ctl") do |f|
					while f.gets
						line = $_
						if (line =~ /hda-platform-(.*)\./)
							platform = $1
						end
						if (line =~ /hda-ctl-([0-9\.\-]+)\.\w+/)
							hda_ctl = $1
						end
					end
				end
			elsif ubuntu?
				open("|apt-cache show hda-platform | grep Version") do |f|
					f.gets
					line = $_
					if (line =~ /Version: (.*)/)
						platform = $1
					end
				end
				open("|apt-cache show hda-ctl | grep Version") do |f|
					f.gets
					line = $_
					if (line =~ /Version: (.*)/)
						hda_ctl = $1
					end
				end
			elsif mac?
				platform = "mac-platform"
				hda_ctl = "mac-hda-ctl"
			else
				platform = "unknown-platform"
				hda_ctl = "unknown-hda-ctl"
			end
			{ :platform => platform, :core => hda_ctl }
		end
	end

	private

	class << self
		def set_platform
			if File.exist?('/etc/issue')
				line = nil
				File.open("/etc/issue", "r") do |issue|
					line = issue.gets
				end
				@@platform = "arch"   if line.include?("Arch")
				@@platform = "debian" if line.include?("Debian")
				@@platform = "ubuntu" if line.include?("Ubuntu")
				@@platform = "fedora" if line.include?("Fedora")
				@@platform = "centos" if line.include?("CentOS")
				@@platform = "mint"   if line.include?("Mint")
			elsif File.exist?('/mach_kernel')
				@@platform = "mac"
			end
			#To ensure that @@platform is either set or nil:
			@@platform ||= nil
			raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
		end

		def service2name(service)
			name = SERVICES[@@platform][service.to_sym]
			name || service
		end

		def file2name(fname)
			name = FILENAMES[@@platform][fname]
			raise "unknown filename '#{fname}' for '#{@@platform}'" unless name
			name
		end

		def pkginstall(pkgs, sha1 = nil)
			if debian? or ubuntu? or mint?
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
			elsif arch?
				c = Command.new "pacman -S --noprogressbar --noconfirm \"#{pkgs}\""
				c.run_now
			else
				raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
			end
		end

		def pkguninstall(pkgs)
			if debian? or ubuntu? or mint?
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
			elsif arch?
				c = Command.new "pacman -R --noprogressbar --noconfirm \"#{pkgs}\""
				c.run_now
			else
				raise "unsupported platform #{@@platform}" unless PLATFORMS.include?(@@platform)
			end
		end
	end

	# class initialization
	set_platform

end
