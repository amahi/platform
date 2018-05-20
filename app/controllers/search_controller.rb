# encoding: UTF-8
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

require 'digest/sha1'

class SearchController < ApplicationController

	before_action :login_required
	layout 'basic'
	theme :theme_resolver

	RESULTS_PER_PAGE = 20

	SEARCH_CACHE = File.join(Rails.root, 'tmp/cache/search')

	EXT_AUDIO = ['aac', 'aif', 'iff', 'm3u', 'm4a', 'mid', 'midi', 'mp3', 'mpa', 'ra', 'ram', 'wav', 'wma']
	EXT_IMAGES = ['mng', 'pct', 'bmp', 'gif', 'jpeg', 'jpg', 'png', 'psd', 'psp', 'thm', 'tif', 'ai', 'drw', 'dxf', 'eps', 'ps', 'svg', '3dm', '3dmf']
	EXT_VIDEO = ['3g2', '3gp', 'asf', 'asx', 'avi', 'flv', 'mkv', 'mov', 'mp4', 'mpg', 'mpeg', 'qt', 'rm', 'swf', 'vob', 'wmv']

	def hda
		@page_title = 'Search Results'
		@search_value = 'HDA'

		if params[:button] && params[:button] == "Web"
			require 'uri'
			redirect_to URI.escape("http://www.google.com/search?q=#{params[:query]}")
		else
			@query = params[:query]
			@page = (params[:page] && params[:page].to_i.abs) || 1
			@rpp = (params[:per_page] && params[:per_page].to_i.abs) || RESULTS_PER_PAGE
			unless use_sample_data?
				@results = hda_search(@query, nil, @page, @rpp)
			else
				# NOTE: this is some sample fake data for development
				@results = SampleData.load('search')
			end
		end
	end

	def images
		@query = params[:query]
		@page = (params[:page] && params[:page].to_i.abs) || 1
		@rpp = (params[:per_page] && params[:per_page].to_i.abs) || RESULTS_PER_PAGE
		@results = hda_search(@query, EXT_IMAGES, @page, @rpp)
		render 'hda'
	end

	def audio
		@query = params[:query]
		@page = (params[:page] && params[:page].to_i.abs) || 1
		@rpp = (params[:per_page] && params[:per_page].to_i.abs) || RESULTS_PER_PAGE
		@results = hda_search(@query, EXT_AUDIO, @page, @rpp)
		render 'hda'
	end

	def video
		@query = params[:query]
		@page = (params[:page] && params[:page].to_i.abs) || 1
		@rpp = (params[:per_page] && params[:per_page].to_i.abs) || RESULTS_PER_PAGE
		@results = hda_search(@query, EXT_VIDEO, @page, @rpp)
		render 'hda'
	end

	def web
	end

protected

	def hda_search(term, filter, page, rpp = RESULTS_PER_PAGE)
		return [] unless term && !term.blank?
		locate_search(term, filter && filter.join('|'), page, rpp)
	end

	# FIXME: implement pagination
	def locate_search(term, filter, page, rpp)
		base = Share.basenames
		# lines to skip
		skip = (page - 1) * rpp
		open locate_cache(term) do |l|
			skipped = 0
			res = []
			while (file = l.gets) && (res.size < rpp)
				file.strip!
				path = pathname(file, base)
				next unless path
				r = locate2result(file, path)
				next unless r
				next if filter && r[:title] !~ /\.(#{filter})$/
				if skipped < skip
					skipped += 1
					next
				end
				res << r
			end
			res
		end
	end

	def locate_cache(term)
		FileUtils.mkdir_p(SEARCH_CACHE)
		sha1 = Digest::SHA1.hexdigest(term)
		cache = File.join(SEARCH_CACHE, sha1)
		# expire old entries in the cache to prevent accumulation (12 hours, index is 24 hours old)
		Dir.glob(File.join(SEARCH_CACHE, '*')) do |f|
			FileUtils.rm_f(f) if Time.now - File.mtime(f) > 12.hours
		end
		# is the search already in the cache? if so, return it, if not make it
		if File.exists?(cache)
			cache
		else
			# ignore case unless the search is done with some capitalization
			case_sensitive = (term =~ /[A-Z]/) ? "" : "-i"
			system "locate #{case_sensitive} -e '#{term}' > #{cache}"
			cache
		end
	end

	def locate2result(file, path)
		begin
			stat = File::Stat.new file
		rescue
			return nil
		end
		unless ["directory", "file"].include? stat.ftype
			raise "can't handle file type #{t} for #{file}"
		end

		{	:title => File.basename(file),
			:path => File.join(path),
			:size => stat.size,
			:owner => begin Etc.getpwuid(stat.uid).name; rescue ; stat.uid.to_s; end,
			:type => File.ftype(file)
		}
	end

	def pathname(file, basenames)
		basenames.each { |b,name| return [name, $1] if file =~ /^#{b}(.*)/ }
		nil
	end
end
