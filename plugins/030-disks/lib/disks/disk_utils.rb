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
	class << self
		def stats
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
				t = i[2].to_i rescue 0
				tempcolor = "cool"
				celsius = "-"
				farenheight = "-"
				if t > 0
					celsius = t.to_s
					tempcolor = "warm" if t > 39
					tempcolor = "hot" if t > 49
					farenheight = (t * 1.8 + 32).to_i.to_s
				end
				d = Hash.new
				d[:device] = i[0]
				d[:model] = model
				d[:temp_c] = celsius
				d[:temp_f] = farenheight
				d[:tempcolor] = tempcolor
				res.push(d)
			end
			res
		end

		def mounts
			s = `df -BK`.split( /\r?\n/ )[1..-1] || ["","Incorrect data returned"]

			mount = []
			res = []
			s.each do |line|
				word = line.split(/\s+/)
				mount.push(word)
			end
			mount.each do |key|
				d = Hash.new
				d[:filesystem] = key[0]
				d[:bytes] = key[1].to_i * 1024
				d[:used] = key[2].to_i * 1024
				d[:available] = key[3].to_i * 1024
				d[:use_percent] = key[4]
				d[:mount] = key[5]
				res.push(d) unless ['tmpfs', 'devtmpfs', 'none'].include? d[:filesystem]
			end
			res.sort { |x,y| x[:filesystem] <=> y[:filesystem] }
		end
	end
end
