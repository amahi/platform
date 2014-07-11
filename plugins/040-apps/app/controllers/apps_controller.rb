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

class AppsController < ApplicationController

	before_filter :admin_required

	# make the JSON calls much more efficient by not invoking these filters
	skip_filter :before_filter_hook, except: [:index, :installed]
	skip_filter :prepare_plugins, except: [:index, :installed]

	def index
		set_title t('apps')
		@inactive = ''
		@apps = App.available

		@apps.each do |app|
			app_setting  = Setting.get_kind(app.identifier,'install_status')
			status = app_setting.value.to_i if app_setting
			if app_setting and status < 100
				id = app.identifier
				timestamp = Setting.get_kind('app_installation','installation_time')
				if timestamp
					time = Time.parse(Time.now.to_s)
					Rails.logger.error(timestamp)
					installation_time = Time.parse(timestamp.value)
					diff = time - installation_time
					if(diff<240)
						@inactive = 'display:none'
					end
					break
				end
			end
		end
	end

	def installed
		set_title t('apps')
		@apps = App.latest_first

		@apps.each do |app|
			app_setting  = Setting.get_kind(app.identifier,'install_status')
			status = app_setting.value.to_i if app_setting
			if app_setting and status>0 and status < 100
				id = app.identifier
				timestamp = Setting.get_kind('app_uninstallation','uninstallation_time')
				if timestamp
					time = Time.parse(Time.now.to_s)
					Rails.logger.error(timestamp)
					installation_time = Time.parse(timestamp.value)
					diff = time - installation_time
					if(diff<240)
						@inactive = 'display:none'
					end
					break
				end
			end
		end
	end

	def install
		identifier = params[:id]
		@app = App.where(:identifier=>identifier).first
		Setting.set('install_status','0',identifier)
		Setting.set('installation_time', Time.now.to_s,'app_installation')
		App.install identifier unless @app
	end

	def install_progress
		identifier = params[:id]
		@app = App.where(:identifier=>identifier).first

		if @app
			@app.reload
			@progress = @app.install_status
			@message = @app.install_message
		else
			@progress = App.installation_status identifier
			@message = App.installation_message @progress
		end
		# we may send HTML if there app is installed or it errored out
		before_filter_hook if @progress >= 100
	end

	def uninstall
		identifier = params[:id]
		@app = App.where(:identifier=>identifier).first
		Setting.set('uninstallation_time', Time.now.to_s,'app_uninstallation')
		@app.uninstall if @app
	end

	def uninstall_progress
		identifier = params[:id]
		@app = App.where(:identifier=>identifier).first
		if @app
			@app.reload
			@progress = @app.install_status
			@message = @app.uninstall_message
		else
			@message = t('application_uninstalled')
			@progress = 0
		end
	end


	def toggle_in_dashboard
		identifier = params[:id]
		app = App.where(:identifier=>identifier).first
		if app.installed
			app.show_in_dashboard = ! app.show_in_dashboard
			app.save
			@saved = true
		end
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

end
