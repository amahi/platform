# Amahi Home Server
# Copyright (C) 2007-2011 Amahi
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

require 'net/http'
require 'digest/sha1'

class Downloader

	HDA_DOWNLOAD_CACHE = "/tmp/amahi-download-cache"
	AMAHI_DOWNLOAD_CACHE_SITE = 'http://mirror.amahi.org'

	class SHA1VerificationFailed < Exception; end
	class TooManyRedirects < Exception; end

	# download a file, but check in the cache first, also
	# check the sha1
	def self.download_and_check_sha1(url, sha1)

		FileUtils.mkdir_p(HDA_DOWNLOAD_CACHE)
		raise SHA1VerificationFailed, "#{url}, sha1sum provided is empty!" unless sha1
		cached_filename = File.join(HDA_DOWNLOAD_CACHE, sha1)
		if File.exists?(cached_filename)
			file = nil
			open cached_filename do |f|
				file = f.read
			end
			new_sha1 = Digest::SHA1.hexdigest(file)
			if new_sha1 == sha1
				puts "NOTE: file #{cached_filename} picked up from cache."
				FileUtils.touch cached_filename
				# return the file name, not the data
				return cached_filename
			else
				puts "WARNING: file #{cached_filename} in cache was found to be corrupted! Discarding it."
			end
		end

		# download if the above fails, i.e. no cached file OR the sha1sum failed!
		download(url, cached_filename, sha1)

		# return the file name, not the data
		cached_filename
	end

	private

	def self.download_direct(url)

		redirect_limit = 5
		ret = ""

		while redirect_limit > 0
			u = URI.parse(url)
			req = Net::HTTP::Get.new(u.path)
			response = Net::HTTP.start(u.host, u.port) { |http| http.request(req) }
			return response.body unless response.kind_of?(Net::HTTPRedirection)
			# it's a redirection
			location = response['location']
			old_url = url
			url = location.nil? ? (response.body.match(/<a href=\"([^>]+)\">/i)[1]) : location
			puts "NOTICE: redirected '#{old_url}' --> '#{url}' ..."
			redirect_limit -= 1
		end
		# reached end of redirect limit]!
		raise TooManyRedirects, "#{url}"
	end

	# try to download from the original download site. if that fails,
	# then try to download from amahi's mirror
	def self.download(url, filename, sha1)
		new_sha1 = "badbadsha1"

		begin

			file = download_direct(url)
			f = open(filename, "w:ASCII-8BIT")
			f.write file
			f.close
			puts "NOTE: file #{filename} written in cache"

			new_sha1 = Digest::SHA1.hexdigest(file)
		rescue => e
			puts "WARNING: primary downloaded of #{url} barfed with exception \"#{e.inspect}\""
		end

		if new_sha1 != sha1
			puts "WARNING: primary downloaded file #{filename} did not pass signature check - got #{new_sha1}, expected #{sha1}"
			new_url = File.join(AMAHI_DOWNLOAD_CACHE_SITE, sha1)
			file = download_direct(new_url)
			f = open(filename, "w")
			f.write file
			f.close
			puts "NOTE: new file #{filename} from Amahi's cache written in the cache"

			new_sha1 = Digest::SHA1.hexdigest(file)
			raise SHA1VerificationFailed, "#{new_url} (from original #{url}), '#{new_sha1}' vs. '#{sha1}' " if new_sha1 != sha1
		end
	end
end
