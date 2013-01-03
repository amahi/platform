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

require 'socket'      # Sockets are in standard library

class DiskUtils

	# return information on hdd temperature - requires hddtemp service running!
	def info
		host = 'localhost'
		port = 7634

		begin
			s = TCPSocket.open(host, port)
		rescue
			return []
		end

		res = ''
		while line = s.gets   # Read lines from the socket
			res += line.chop      # And print with platform line terminator
		end
		s.close               # Close the socket when done

		disks = res.split '||'

		res = []
		disks.each do |disk|
			# split the info and do cleanup
			i = disk.gsub(/^\||\|$/, '').split('|')
			model = i[1].gsub(/[^A-Za-z0-9\-_\s\.]/, '') rescue "Unkown"
			next if model == '???'
			d = Hash.new
			d[:device] = i[0]
			d[:model] = model
			d[:temperature] = (i[2] =~ /(^\*$)|nos|err/i) ? nil : i[2]
			res.push(d)
		end
		res
	end

private

	# old version, not server based. in F12, hddtemp does not
	# work for apache
	def info_old
		res = []

		open("|hddtemp 2>&1 " + "/dev/[hs]d[a-z]") do |dev|
			model = 'UNKNOWN MODEL - report it!'
			temp = nil
			while dev.gets
				data = Hash.new
				if ($_ =~ /^\/dev\/[hs]d[a-z]/)
					cur = $_.split(":")
					cur[1].gsub!(/[^A-Za-z0-9\-_\s\.]/, '')
					if (cur[2] =~ /sensor/)
						data[:device] = cur[0]
						data[:model] = cur[1]
						data[:temperature] = nil
					else
						data[:device] = cur[0]
						data[:model] = cur[1]
						temp = cur[2]
						temp = temp.gsub(/\D/, "")
						data[:temperature] = temp
					end
					res.push(data)
				end

			end
		end
		res
	end

end
