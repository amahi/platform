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

# router driver library for DD-wrt v24

require 'uri'
require 'net/http'

class Ddwrt < RouterDriver

	# Base URL for reaching the router - FIXME - this should be in the upper class
	BASE = "http://router/"
	# Default admin user/password for this router
	# FIXME:one day we will use this for autoprobing and
	# avoid users having to even enter the password!
	DEFAULT_AUTH = { :user => 'admin', :password => 'admin' }

	# models that this driver can handle
	def self.name
		"DD-WRT"
	end

	def self.models
		["v24"]
	end

	def self.support
		%(dmz dhcp openvpn)
	end

	# writes a firewall rule
	def self.write_rule(rule)
		net = Setting.get 'net'

		case rule.kind
		when 'port_filter'
		#	url += "&fromPort=#{range_lo(rule)}&toPort=#{range_hi(rule)}"
		when 'ip_filter'
		#	url += "&ip=#{net_ip(rule)}"
		when 'mac_filter'
		#	url += "&mac=#{rule.mac.tr_s(':', '')}"
		when 'port_forward'

#			form = {'submit_button' => 'Forward',
#				'action' 	=> 'Apply',
#				'change_action' => 'gozila_cgi',
#				'submit_type' 	=> 'add_forward',
#				'forward_port' 	=> '13'}
#	
#			do_post(BASE + 'apply.cgi', form)
#			sleep 1
#			form = {'submit_button' => 'Forward',
#				'action' 	=> 'Apply',
#				'change_action' => '',
#				'submit_type' 	=> '',
#				'forward_port' 	=> '13',
#				'name0' 	=> 'TorrentFlux',
#				'from0' 	=> '49160',
#				'to0' 		=> '49300',
#				'pro0' 		=> 'both',
#				'ip0' 		=> '192.168.1.101',
#				'enable0' 	=> 'on',
#				'name1' 	=> 'test',
#				'from1' 	=> "#{range_lo rule}",
#				'to1' 		=> "#{range_hi(rule)}",
#				'pro1' 		=> "#{prot rule.protocol}",
#				'ip1' 		=> "#{net}" + '.' + "#{net_ip(rule)}",
#				'enable1' 	=> 'on'}
#				do_post(BASE + 'apply.cgi', form)
		when 'url_filter'
#		#	url += "&url=#{url_encode rule.url}"
		else
#			raise "error - #{File.dirname(__FILE__)} cannot generate url for '#{rule.kind}'"
		end
	end

	# set the DMZ to this (full) ip address
	def self.set_dmz(ip)
	iparray = ip.split('.')
	lastoctet = iparray[3]
		if lastoctet and not lastoctet.blank?
			form = {'submit_button' => 'DMZ',
				'action' 	=> 'ApplyTake',
				'change_action' => '',
				'submit_type' 	=> '',
				'dmz_enable' 	=> '1',
				'dmz_ipaddr' 	=> "#{lastoctet}"}
			do_post(BASE + "apply.cgi", form)
		else
			form = {'submit_button' => 'DMZ',
				'action' 	=> 'ApplyTake',
				'change_action' => '',
				'submit_type' 	=> '',
				'dmz_enable' 	=> '0'}
			do_post(BASE + "apply.cgi", form)
		end
	
	end

	def self.set_global(kind, value)
		case kind
		when 'dhcp_in_router'
			self.dhcp_server(value == '1')
			# sleep to let the router reboot
			sleep 10
		when 'vpn'
			if value == '1'
				self.vpn_enable
			else
			
				self.vpn_disable
			end
			# sleep to let the router reboot
			sleep 10
		else
			raise "cannot handle set_global('#{kind}', #{value})"
		end
	end

	# delete a firewall rule
	def self.delete_rule(rule)
	end
	
	# turn on VPN and port forwarding
	def self.vpn_enable
		hdaip = Setting.get('net') + "." + Setting.get('self-address')

		form = {'submit_button' => 'ForwardSpec',
			'action' 	=> 'Apply',
			'change_action' => 'gozila_cgi',
			'submit_type' 	=> 'add_forward_spec',
			'forward_spec' 	=> '13'}

		do_post(BASE + 'apply.cgi', form)
		sleep 2

		form = {'submit_button' => 'ForwardSpec',
			'action' 	=> 'ApplyTake',
			'change_action' => '',
			'submit_type' 	=> '',
			'forward_spec' 	=> '13',
			'name0' 	=> 'vpn',
			'from0' 	=> '1194',
			'pro0' 		=> 'udp',
			'ip0' 		=> "#{hdaip}",
			'to0' 		=> '1194',
			'enable0' 	=> 'on'}

		do_post(BASE + 'apply.cgi', form)
	end

	# turn off VPN and delete the port forwarding
	def self.vpn_disable
		hdaip = Setting.get('net') + "." + Setting.get('self-address')

		form = {'submit_button' => 'ForwardSpec',
			'action' 	=> 'Apply',
			'change_action' => 'gozila_cgi',
			'submit_type' 	=> 'remove_forward_spec',
			'forward_spec' 	=> '13',
			'name0' 	=> 'vpn',
			'from0' 	=> '1194',
			'pro0' 		=> 'udp',
			'ip0' 		=> "#{hdaip}",
			'to0' 		=> '1194'}

		do_post(BASE + 'apply.cgi', form)
	end


	def self.dhcp_server(enable)
		form = {'submit_button' 	=> 'index',
			'action' 		=> 'ApplyTake',
			'change_action'		=> '',
			'submit_type' 		=> '',
			'dhcpfwd_enable' 	=> '0'}
		if enable
			form.merge!({	'lan_proto' 	=> 'dhcp',
					'dhcp_check' 	=> '',
					'dhcp_start' 	=> '2',
					'dhcp_num' 	=> '50',
					'dhcp_lease' 	=> '1440',
					'wan_dns' 	=> '4',
					'wan_dns0_0' 	=> '0',	'wan_dns0_1' => '0', 'wan_dns0_2' => '0', 'wan_dns0_3'	=> '0',
					'wan_dns1_0' 	=> '0',	'wan_dns1_1' => '0', 'wan_dns1_2' => '0', 'wan_dns1_3'	=> '0',
					'wan_dns2_0' 	=> '0',	'wan_dns2_1' => '0', 'wan_dns2_2' => '0', 'wan_dns2_3'	=> '0',
					'wan_wins' 	=> '4',
					'wan_wins_0' 	=> '0',	'wan_wins_1' => '0', 'wan_wins_2' => '0', 'wan_wins_3'  => '0'})
		else
			form.merge!({	'lan_proto' 	=> 'static',
					'dhcp_check' 	=> ''})
		end
		
		do_post(BASE + 'apply.cgi', form)
	end

	def self.auth
		super auth
	end

end
