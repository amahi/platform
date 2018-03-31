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
require 'active_support/core_ext/numeric/time'

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

				time_ago = convert_time_to_words(item[2]) rescue item[2]

				output << { :title => item[1], :link => item[0],
					:date => time_ago,
				:comments => item[3] }

			end
		end
		output
	end	

	def self.convert_time_to_words(weeks)
		weeks_count = weeks.gsub("weeks ago","").to_i 
		past_time = Time.now - weeks_count.week
		time_diff = Time.now.to_i - past_time.to_i

		if time_diff > 31556926 # seconds in a year
			return (time_diff/31556926).to_s+' years ago'
		elsif time_diff > 2630016 # seconds in a month
			return (time_diff/2630016).to_s+' months ago'
		elsif time_diff > 604800 # seconds in a week
			return (time_diff/604800).to_s+' weeks ago'
		elsif time_diff > 86400 # seconds in a day
			return (time_diff/86400).to_s+' days ago'
		end
	end

end
