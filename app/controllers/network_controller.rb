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

class NetworkController < ApplicationController

	before_filter :admin_required
	before_filter :setup_router

	def toggle_setting
		id = params[:id]
		kind = params[:kind]
		s = Setting.find id
		old = s.value
		s.value = (1 - s.value.to_i).to_s
		s.save!
		r = RouterDriver.current_router
		begin
			r.set_global(kind, s.value)
			render :partial => "network/router/#{kind}", :locals => { :setting => s }
		rescue
			# FIXME - handle errors in a way that is
			# visible to the user!
			s.value = old
			s.save!
			render :partial => 'network/router/errors', :status => :not_acceptable, :locals => { :msg => t('router_setting_failed') }
		end
	end

	def set_dmz
		# FIXME - no error checking
		ip = params[:ip]
		s = Setting.find_by_name 'dmz'
		old = s.value
		s.value = ip
		s.save!
		begin
			@net = Setting.get 'net'
			r = RouterDriver.current_router
			r.set_dmz ip.blank? ? '' : @net + '.' + ip
			render :partial => "network/router/dmz", :locals => { :dmz => s }
		rescue
			s.value = old
			s.save!
			render :partial => 'network/router/dmz_error', :status => :not_acceptable, :locals => { :msg => t('setting_dmz_failed') }
		end
	end

	def new_router_model
		klassname = params[:model]
		Setting.set_kind('network', 'router_model', klassname)
		setup_router
		render :partial => "network/router/settings"
	end

	def update_router_user_pwd
		id = params[:id]
		value = params[:value]
		s = Setting.find id
		s.update_attribute(:value, obfuscate(value))
		render :text => "*******"
	end

	def router_selector
		render :partial => 'network/router/selector'
	end

	def change_dhcp_lease_time
		id = params[:id]
		value = params[:value]
		s = Setting.find id
		lease = value.to_i
		lease = 300 if lease < 300
		lease = 86400 if lease > 86400
		s.update_attribute(:value, value)
		# FIXME - only dhcpd needs to be set, and only if enabled!
		system "hda-ctl-hup"
		# prevent the fast clickers from bringing down the house
		sleep 2
		render :text => "#{s.value}"
	end

	def change_gateway
		id = params[:id]
		value = params[:value]
		s = Setting.find id
		gw = value.to_i
		gw = 1 if gw < 1
		gw = 254 if gw > 254
		s.update_attribute(:value, gw.to_s)
		# FIXME - need to change the alias for "router"!
		# FIXME - this needs to be enabled
		# system "hda-ctl-hup"
	end

private

end
