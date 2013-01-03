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


class PartitionUtils
	attr :file
	attr :info

	def initialize
		@file = '/etc/mtab'
		@info = []
		begin
			f = File.open('/etc/mtab')
		rescue
			return @info
		end
		while f.gets
			if ($_.match(/^\/dev/))
				# data = ($_.split)[0..3]
				p = ($_.split)[0..3]
				data = Hash.new
				device = part2device(p[0])
				path = cleanup_path(p[1])
				next if path == "/boot" # C. Ayuso
				data[:device] = device
				(total, free) = disk_stats(path)
				data[:bytes_total] = total
				data[:bytes_free] = free
				data[:path] = path
				@info.push(data)
			end
		end
		f.close
	end

private

	# return device
	def part2device(part)
		part[/.?[^0-9]*/]
	end

	def cleanup_path(path)
		path.gsub(/\\040/, ' ')
	end

	def disk_stats(path)
		size = 128
		unpack_fmt = 'l_l_l_l_l_l_l_l_l_l_l_l_l_l_l_l_'
		buffer = ' ' * size
		# FIXME!: this is 137 in x86_64!!
		# asm/unistd.h __NR_statfs 99
		begin
			open('|uname -i') do |uname|
				arch = uname.gets
				if (arch =~ /64/)
					syscall(137, path, buffer)
				else
					syscall(99, path, buffer)
				end
			end
			type, bsize, blocks, bfree, bavail, files, ffree, namelen =
				buffer.unpack(unpack_fmt).values_at(0, 1, 2, 3, 4, 5, 6, 9)
			# return total bytes, free bytes
			[blocks * bsize, bfree * bsize]
		rescue => e
			RAILS_DEFAULT_LOGGER.error("******** disk stats error for #{path}: #{e.inspect}")
			[0, 0]
		end
	end

end

