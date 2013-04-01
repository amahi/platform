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

class WebappController < ApplicationController
	before_filter :admin_required

	VALID_NAME = Regexp.new "^[A-Za-z][A-Za-z0-9\-]+$"

	def create
		# FIXME - check check check!
		name = params[:name].strip
		path = params[:path].sub(/\/+$/, '')
		path.gsub!(/\/+/, '/')
		wa = Webapp.create(:name => name, :path => path)
		@webapps = Webapp.find :all
		render :partial => "index"
	end

	def delete
		# FIXME - check check check!
		wa = Webapp.find params[:id]
		wa.destroy
		webapps = Webapp.find(:all)
		render :partial => 'list', :locals => { :webapps => webapps }
	end

	def new_name_check
		n = params[:name]
		if n.nil? or n.blank?
			render :partial => 'name_bad'
			return
		end
		if (not (valid_name?(n))) or (n.size > 32)
			render :partial => 'name_bad'
			return
		end
		n = n.strip
		a = DnsAlias.find_by_alias(n)
		if a.nil?
			# no such alias, ok to create it
			@name = n
			render :partial => 'name_available'
		else
			render :partial => 'name_unavailable'
		end
	end

	def new_path_check
		n = params[:path]
		if n.nil? or n.blank?
			render :partial => 'path_bad'
			return
		end
		unless valid_path?(n)
			render :partial => 'path_bad'
			return
		end
		if File.exist? n
			render :partial => 'path_exists'
		else
			render :partial => 'path_available'
		end
	end

	def update_name
		id = params[:id]
		wa = Webapp.find(id)
		unless params[:value].blank?
			name = params[:value]
			wa.name = name
			wa.save
			wa.reload
		end
		name = wa.name
		render :text => name
	end

	def update_path
		id = params[:id]
		wa = Webapp.find(id)
		unless params[:value].blank?
			path = params[:value]
			# check it exists!
			if files_exist?(path)
				wa.path = path
				wa.save
				wa.reload
			else
				# FIXME - report (somehow) why we did not
				# make it! user must be confused!?!
				# alternatively, create it!
				raise PathDoesNotExist(path)
			end
		end
		path = wa.path
		render :text => path
	end

	def toggle_login_required
		begin
			webapp = Webapp.find params[:id]
			webapp.login_required = ! webapp.login_required
			webapp.save
		rescue
		end
		render :partial => 'login_required', :locals => { :webapp => webapp }
	end


private

	def valid_name?(nm)
		return false unless (nm =~ VALID_NAME)
		true
	end

	def valid_path?(path)
		return false if path.size > 250
		return false unless path =~ /^\//
		return false unless path =~ /^[A-Za-z0-9_\/-]+$/
		return false if path =~ /\/$/
		return false if path =~ /\/\/+/
		true
	end

	def files_exist?(path)
		return false unless File.exist?(path)
		return false unless File.exist?(File.join(path, "html"))
		return false unless File.exist?(File.join(path, "logs"))
		true
	end

end
