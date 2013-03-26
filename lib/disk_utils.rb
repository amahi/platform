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
			host = '10.1.1.155'
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

			#res = "|/dev/sda|Intel|32|*|" #For testing on OSX
			disks = res.split '||'

			res = []
			disks.each do |disk|
				# split the info and do cleanup
				i = disk.gsub(/^\||\|$/, '').split('|')
				model = i[1].gsub(/[^A-Za-z0-9\-_\s\.]/, '') rescue "Unkown"
				next if model == '???'
				t = (i[2] =~ /(^\*$)|nos|err/i) ? nil : i[2].to_i
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
			s = `df -BM`.split( /\r?\n/ )[1..-1] || ["","Incorrect data returned"]#Fedora and Ubuntu
			#Test string for ue on systems with noncompatible DF
			#s = "Filesystem                    1M-blocks   Used Available Use% Mounted on
#rootfs                           73886M 15406M    54727M  22% /
#udev                                10M     0M       10M   0% /dev
#tmpfs                              387M     1M      386M   1% /run
#/dev/mapper/netmon-root          73886M 15406M    54727M  22% /
#tmpfs                                5M     0M        5M   0% /run/lock
#tmpfs                              773M     1M      773M   1% /run/shm
#/dev/sda1                          228M    49M      167M  23% /boot
#/dev/mapper/database-database    74588M  3617M    67182M   6% /database".split( /\r?\n/ )[1..-1] #String to use for testing on OSX
			mount = []
			res = []
			s.each do |line|
				word = line.split(/\s+/)
				mount.push(word)
			end
			mount.each do |key|
				d = Hash.new
				d[:filesystem] = key[0]
				d[:blocks] = key[1]
				d[:used] = key[2]
				d[:available] = key[3]
				d[:use_percent] = key[4]
				d[:mount] = key[5]
				res.push(d) if d[:blocks].to_i > 0
			end
			res
		end
	end
end
