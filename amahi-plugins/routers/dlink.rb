# Amahi Home Server
# Copyright (C) 2007-2010 Amahi
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

# router driver library for DLINK DI-614+

require 'uri'
require 'net/http'

class Dlink < RouterDriver

	# Base URL for reaching the router - FIXME - this should be in the upper class
	BASE = "http://router"
	# Default admin user/password
	DEFAULT_AUTH = { :user => 'admin', :password => 'admin' }

	# look for this string in the body of the post
	POST_SUCCESS_MARKER = "Settings Saved"

	# models that this driver can handle
	def self.name
		"D-Link"
	end

	def self.models
		["DI 614+"]
	end

	def self.support
		%w(dmz dhcp)
	end

	# set the DMZ to this (full) ip address
	def self.set_dmz(ip)
		url = [BASE, 'dmz.cgi'].join '/'
		iparray = ip.split('.')
		lastoctet = iparray[3]
		if lastoctet and not lastoctet.blank?
			form = {'dmzEnable'	=> '1',
				'dmzIP4' 	=> lastoctet }
			self.http_post(url, form)
		else
			gw = Setting.get('gateway')
			form = {'dmzEnable'	=> '0',
				'dmzIP4'	=> gw }
			self.http_post(url, form)
		end
	end


	def self.set_global(kind, value)
		case kind
		when 'dhcp_in_router'
			self.dhcp_server(value == '1')
			# sleep to let it reboot
			sleep 4
		when 'vpn'
			full_ip = Setting.get('net') + "." + Setting.get('self-address')
			self.openvpn(value == '1', full_ip)
		else
			raise "cannot handle set_global('#{kind}', #{value})"
		end
	end

	# manage the DHCP server in the router
	def self.dhcp_server(enable)
		# sent the range arbitrarily to something below 100
		url = [BASE, 'h_dhcp.cgi'].join '/'
		form = { 'dhcpsvr' => '1', 'startIP4' => '30', 'endIP4' => '40', 'lease' => '3600' }
		form['dhcpsvr'] = '0' unless enable
		self.http_post(url, form)
	end

	# OpenVPN port management - FIXME - not working!! do not
	# know how to remove an entry once added!!
	def self.openvpn(enable, full_ip)
		url = [BASE, 'vs.cgi'].join '/'
		form = { 'editrow' => '-1', 'delrow' => '0', 'enable' => '1', 'name' => 'Amahi%20OpenVPN', 'ip' => full_ip, 'protocol' => '17', 'priPort' => '1194', 'pubPort' => '1194', 'schd' => '0' }
		unless enable
			form['enable'] = '0'
			form['delrow'] = '1'
		end
		self.http_post(url, form)
	end

	def self.auth
		super auth
	end

protected

	def self.http_post(url, form)
		do_post(url, form, POST_SUCCESS_MARKER)
	end

end
