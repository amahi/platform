#####################################################################
#
#  Copyright 2008-2009 Amahi Inc. - All Rights Reserved
#
#  This source module contains confidential and proprietary
#  information of Amahi Inc. It is not to be disclosed or used
#  except in accordance with applicable agreements. This
#  copyright notice does not evidence any actual or intended
#  publication of such source code.
#
#####################################################################

require 'open-uri'
require 'ping'
require 'rubygems'
require 'active_support/core_ext/numeric/time'
require 'action_view'
require 'action_view/helpers'
include ActionView::Helpers::DateHelper

class AmahiNews

	def self.top(nitems = 5)
		ret = nil
		begin
			# double protection
			site = 'blog.amahi.org'
			if Ping.pingecho(site, 2, 'http')
				ret = parse_feed("https://#{site}/news/2/", nitems) rescue nil
			end
		rescue
			ret = nil
		end
		ret
	end

	private

	def self.parse_feed (url, length = 5)
		output = [];
		open(url) do |http|
			result = ActiveSupport::JSON.decode(http.read)
			result['news'].each_with_index do |item, i|
				return output if ++i == length
				output << { :title => item[1], :link => item[0],
					:date => convert_time_to_words(item[2]),
				:comments => item[3] }
			end
		end
		output
	end	

	def self.convert_time_to_words(weeks)
		weeks_count = weeks.gsub("weeks ago","").to_i 
		time_ago_in_words(Time.now - weeks_count.week) + ' ago'
	end

end
