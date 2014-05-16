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
		@advanced_settings = Setting.where(:name=>'advanced').first
		@guest = Setting.where(:name=>"guest-dashboard").first
		@version = Platform.platform_versions
	end

	def servers
		unless @advanced
			redirect_to settings_engine_path
		else
			@message = nil
			unless use_sample_data?
				@servers = Server.all
			else
				@message = "NOTE: these servers are fake data! Interacting with them will not work."
				@servers = SampleData.load('servers')
			end
		end
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

  def refresh
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    render 'server_status'
  end

  def start
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    @server.do_start
    render 'server_status'
  end

  def stop
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    @server.do_stop
    render 'server_status'
  end

  def restart
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    @server.do_restart
    render 'server_status'
  end

  def toggle_monitored
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    @server.toggle!(:monitored)
    render 'server_status'
  end

  def toggle_start_at_boot
    sleep 2 if Rails.env.development?
    @server = Server.find(params[:id])
    @server.toggle!(:start_at_boot)
    render 'server_status'
  end

	# index of all themes
	def themes
		@themes = Theme.available
	end

	def activate_theme
		s = Setting.where(:name=> "theme").first
		s.value = params[:id]
		s.save!
		# redirect rather than render, so that it re-displays with the new theme
		redirect_to settings_engine.themes_path
	end

end
