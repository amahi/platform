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

require 'timeout'
require 'socket'

class Ping
	def self.pingecho(host, timeout=5, service="echo")
		begin
			timeout(timeout) do
				s = TCPSocket.new(host, service)
				s.close
			end
		rescue Errno::ECONNREFUSED
			return true
		rescue   Timeout::Error, StandardError
			return false
		end
		return true
	end
end
