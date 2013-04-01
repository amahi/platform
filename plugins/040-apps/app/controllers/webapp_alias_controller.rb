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

class WebappAliasController < ApplicationController
	before_filter :admin_required

	def new
		@id = params[:id]
	end

	def index
		@wa = Webapp.find(params[:id])
		raise "Webapp with id=#{params[:id]} cannot be found" unless @wa
		render :partial => "webapp/webapp_aliases", :locals => { :webapp => @wa }
	end

	def create
		@wa = Webapp.find(params[:id])
		raise "Webapp with id=#{params[:id]} cannot be found" unless @wa
		@waa = WebappAlias.find_by_name(params[:name])
		if @waa
			prev = @waa.webapp_id
			@waa.webapp_id = @wa.id
			@waa.save!
			Webapp.find(prev).save
		else
			@waa = WebappAlias.create(:name => params[:name], :webapp_id => @wa.id)
		end
		render :partial => "webapp/webapp_aliases", :locals => { :webapp => @wa }
	end

	def destroy
		@waa = WebappAlias.find(params[:id]) rescue nil
		@waa.destroy if @waa
		@wa = Webapp.find(params[:webapp]) rescue nil
		return unless @wa
		render :partial => "webapp/webapp_aliases", :locals => { :webapp => @wa }
	end
end
