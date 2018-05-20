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

class CalendarController < ApplicationController
	before_action :admin_required
	theme :theme_resolver

	def initialize
		@page_title = t('calendars')
	end

	def index
		Dir.chdir("/var/hda/calendar/html")
		@calendars = Dir["*.ics"]
	end

	def remove
		calname = params[:name]
		return if calname.nil? or calname.blank?
		# FIXME: this is a bit brute force. the proper way would be using a {CAL/WEB}DAV API.
		Dir.chdir("/var/hda/calendar/html") do
			FileUtils.rm_rf(calname)
			FileUtils.rm_rf(".DAV/" + calname + ".pag")
			FileUtils.rm_rf(".DAV/" + calname + ".dir")
			@calendars = Dir["*.ics"]
		end
		@has_ical = App.where(:name => 'iCalendar').first != nil
		render :partial => 'calendar/calendar', :collection => @calendars, :locals => { :has_ical => @has_ical }
	end

	def new
		calname = params[:name].strip
		return if calname.nil? or calname.blank?
		fname = calname + ".ics"
		Dir.chdir("/var/hda/calendar/html") do
			unless File.exists? fname
				open(calname + ".ics", "w") do |f|
					f.write empty_calendar(calname)
				end
			end
			@calendars = Dir["*.ics"]
		end
		@has_ical = App.where(:name=>'iCalendar').first != nil
		render :partial => 'calendar/calendar', :collection => @calendars, :locals => { :has_ical => @has_ical }
	end

private
	def empty_calendar(name)
		ret = [	"BEGIN:VCALENDAR",
			"METHOD:PUBLISH",
			"PRODID:-//Amahi//platform 5.3//EN",
			"CALSCALE:GREGORIAN",
			"X-WR-CALNAME:%s",
			"VERSION:2.0",
			"END:VCALENDAR",
			""].join("\n")
		ret % [name]
	end

end
