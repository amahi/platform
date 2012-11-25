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

require "router_driver"

class Firewall < ActiveRecord::Base

  scope :by_kind, lambda{|kind| where(:kind => kind)}

	scope :port_forwards, by_kind('port_forward')
	scope :port_filters, by_kind('port_filter')
	scope :ip_filters, by_kind('ip_filter')
	scope :mac_filters, by_kind('mac_filter')
	scope :url_filters, by_kind('url_filter')

  scope :by_date, order('updated_at ASC')

	after_save	:update_rule

  protected

	def update_rule
		begin
			rt = RouterDriver.current_router
			rt.write_rule self if rt
		# rescue
			# FIXME - sshh, quiet, for now 
		end
	end

end
