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

class SearchController < ApplicationController

	before_filter :login_required

	RESULTS_PER_PAGE = 60

	EXT_AUDIO = ['aac', 'aif', 'iff', 'm3u', 'm4a', 'mid', 'midi', 'mp3', 'mpa', 'ra', 'ram', 'wav', 'wma']
	EXT_IMAGES = ['mng', 'pct', 'bmp', 'gif', 'jpeg', 'jpg', 'png', 'psd', 'psp', 'thm', 'tif', 'ai', 'drw', 'dxf', 'eps', 'ps', 'svg', '3dm', '3dmf']
	EXT_VIDEO = ['3g2', '3gp', 'asf', 'asx', 'avi', 'flv', 'mkv', 'mov', 'mp4', 'mpg', 'mpeg', 'qt', 'rm', 'swf', 'vob', 'wmv']

	def initialize
		@page_title = 'Search Results'
		@search_value = 'HDA'
	end

	# FIXME: this broke badly with a previous rails release!
	# rigged as is for now
	def hda
		if params[:button] && params[:button] == "Web"
			require 'uri'
			redirect_to URI.escape("http://www.google.com/search?q=#{params[:query]}")
		else
			@query = params[:query]
			@results = hda_search(@query)
		end
	end

	def images
		@query = params[:query]
		@results = hda_search(@query, EXT_IMAGES)
		render :template => 'search/hda'
	end

	def audio
		@query = params[:query]
		@results = hda_search(@query, EXT_AUDIO)
		render :template => 'search/hda'
	end

	def video
		@query = params[:query]
		@results = hda_search(@query, EXT_VIDEO)
		render :template => 'search/hda'
	end

	def web
	end

protected

	def hda_search(term, filter = nil)
		res = locate_search(term)
		return res unless filter
		f = filter.join('|')
		res.select { |r| r[:title] =~ /\.(#{f})$/ }
	end

	# FIXME: implement pagination
	def locate_search(term)
		# ignore case
		case_sensitive = (term =~ /[A-Z]/) ? "" : "-i"
		base = Share.basenames
		open "| locate #{case_sensitive} -e #{term}" do |l|
			res = []
			while file = l.gets
				file.strip!
				path = pathname(file, base)
				next unless path
				r = locate2result(file, path)
				res << r if r
				# return res if (nresults -= 1) == 0
			end
			res
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
		return nil
	end
end
