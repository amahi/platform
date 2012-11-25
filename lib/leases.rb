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


require 'date'
require 'platform'

class Leases

	LEASEFILE = Platform.file_name(:dhcpleasefile)

	def self.all
		leases = read_lease("#{LEASEFILE}~")
		new_leases = read_lease(LEASEFILE)
		new_leases.each{|mac, entry| leases[mac] || leases[mac] = {}; leases[mac].merge!(entry)}
		leases
	end

	def self.active(leases)
		leases.delete_if { |lease| lease{:state} == 'free' }
	end

private

	def self.read_lease(file)
		res = {}
		return res unless File.exists?(file)
		current = {}
		File.foreach(file) do |l|
			next if l =~ /^\s*\#/
			if l =~ /^\s*lease\s+(([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+))\s*\{\s*$/
				current = {}
				current[:ip] = $1
				current[:name] = sprintf("h%03d", $5)
				current[:mac] = nil
				# puts "lease: #{l}"
			elsif l =~ /^\s*client-hostname\s*\"([^"]*)\"/
				current[:name] = $1
			elsif l =~ /^\s*binding\s+state\s+(\w+)/
				current[:state] = $1
			elsif l =~ /^\s*cltt\s+\d\s+(.+);/
				current[:last_seen] = Date.parse($1)
			elsif l =~ /^\s*hardware\s+ethernet\s+(..:..:..:..:..:..)/
				current[:mac] = $1
			elsif l =~ /^\s*\}\s*$/
				# FIXME - this assumes the leases file has leases overriding each other in order!
				# create the entry for this device if it does not exist and there is something in the mac
				if current[:mac]
					res[current[:mac]] = {} unless res[current[:mac]]
					# for each field in the current lease, update the resulting hash
					current.each{|k,v| res[current[:mac]][k] = v }
					# puts "lease end: #{l}"
				end
			end
		end
		res
	end

end
