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

class ServerController < ApplicationController

	before_action :admin_required

	def start
		id = permitted_params.permit[:id]
		server = Server.find id
		server.do_start
		sleep 1
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end

	def restart
		id = permitted_params.permit[:id]
		server = Server.find id
		server.do_restart
		sleep 1
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end

	def stop
		id = permitted_params.permit[:id]
		server = Server.find id
		server.do_stop
		sleep 1
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end

	def refresh
		id = permitted_params.permit[:id]
		server = Server.find id
		sleep 1
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end

	def toggle_monitored
		id = permitted_params.permit[:id]
		server = Server.find id
		server.monitored = ! server.monitored
		server.save!
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end

	def toggle_start_at_boot
		id = permitted_params.permit[:id]
		server = Server.find id
		server.start_at_boot = ! server.start_at_boot
		server.save!
		render :partial => 'status', :locals => { :server => server, :pids => server.pids }
	end
end
