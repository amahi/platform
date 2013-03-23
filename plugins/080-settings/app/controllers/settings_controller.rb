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

class SettingsController < ApplicationController

	before_filter :admin_required

	def index
		@page_title = t 'settings'
		@available_locales = locales_implemented
		@advanced = Setting.find_by_name('advanced')
		@guest = Setting.find_by_name("guest-dashboard")
		@version = {}
		@version[:platform] = "xyz (FIXME)"
		@version[:core] = "xyz (FIXME)"
	end

	def change_language
		sleep 2 if development?
		l = params[:locale]
		if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
			cookies['locale'] = { :value => params[:locale], :expires => 1.year.from_now }
		end
		render json: { status: 'ok' }
	end

	def toggle_setting
		sleep 2 if development?
		id = params[:id]
		s = Setting.find id
		s.value = (1 - s.value.to_i).to_s
		if s.save
			render json: { status: 'ok' }
		else
			render json: { status: 'error' }
		end
	end

	def reboot
		c = Command.new("reboot")
		c.execute
		render :text => t('rebooting')
	end

	def poweroff
		c = Command.new("poweroff")
		c.execute
		render :text => t('powering_off')
	end

	def servers
		@servers = Server.all
	end
end
