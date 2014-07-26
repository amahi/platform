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

module TabsHelper

	def tab_class(tab)
		klass = 'active' if params[:controller] == tab.id
		klass = 'active' if !Tab.find(params[:controller]) && Tab.ischild(params[:controller],tab)
		klass += " empty" unless tab.subtabs?
		klass
	end

	def subtab_class(action = nil, tab_id)
		((action == params[:action] && params[:controller] == tab_id) or (action == params[:controller] && Tab.find(params[:controller])==nil) ) ? 'active' : ''
	end

	def nav_class(tabs)
		tabs.each do |tab|
			return "subtab" if is_subtab(tab) && tab.subtabs?
		end
		""
	end

	def is_subtab(tab)
	  return true if params[:controller] == tab.id
	  return true if !Tab.find(params[:controller]) && Tab.ischild(params[:controller],tab)
	  false
	end

	def debug_tab?
		advanced? || debug?
	end

	def advanced?
		(s = Setting.where(:name=>'advanced').first) && s.set?
	end

	def debug?
		#TODO
		false
	end
end


