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

# router driver library for Linksys devices

class Linksys < RouterDriver

	# Base URL for reaching the router - FIXME - this should be in the upper class
	BASE = "http://router"
	# default admin user/password
	DEFAULT_AUTH = { :user => 'admin', :password => 'admin' }

	# look for this string in the body of the post
	POST_SUCCESS_MARKER = "Settings are successful."

	# models that this driver can handle
	def self.name
		"Linksys"
	end
	def self.models
		["WRT54G Family"]
	end

	def self.support
		%w(dmz dhcp)
	end

	def self.set_dmz(ip)
		url = [BASE, "apply.cgi"].join '/'
		iparray = ip.split('.')
		lastoctet = iparray[3]
		if lastoctet and not lastoctet.blank?
			form = {'submit_button' => 'DMZ',
				'action' 	=> 'Apply',
				'change_action' => '',
				'dmz_enable' 	=> '1',
				'dmz_ipaddr' 	=> lastoctet }
		else
			form = {'submit_button' => 'DMZ',
				'action' 	=> 'Apply',
				'change_action' => '',
				'dmz_enable' 	=> '0'}
		end
		self.http_post(url, form)
	end

	def self.set_global(kind, value)
		case kind
		when 'dhcp_in_router'
			self.dhcp_server(value == '1')
		else
			raise "cannot handle set_global('#{kind}', #{value})"
		end
	end

	# DHCP server in the router
	def self.dhcp_server(enable)
		url = [BASE, "apply.cgi"].join '/'
		form = {'submit_button' 	=> 'index',
			'action' 		=> 'Apply',
			'change_action'		=> '',
			'submit_type' 		=> '',
			'dhcp_check'	 	=> ''}
		if enable
			form.merge!({	'lan_proto' 		=> 'dhcp',
					'dhcp_check' 		=> '',
					'dhcp_start' 		=> '200',
					'dhcp_num' 		=> '50',
					'dhcp_lease' 		=> '600' })
		else
			form.merge!({	'lan_proto' 	=> 'static' })
		end
		self.http_post(url, form)
		# sleep to let the settings take effect
		sleep 2
	end

	def self.auth
		super auth
	end

protected

	def self.http_post(url, form)
		do_post(url, form, POST_SUCCESS_MARKER)
	end

end

