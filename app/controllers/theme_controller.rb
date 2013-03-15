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

class ThemeController < ApplicationController

	before_filter :admin_required

	MIME_TYPES = {'.css' => 'text/css',   '.js' => 'text/javascript',
                '.jpg' => 'image/jpeg', '.png' => 'image/png',
		".gif" => 'image/gif' }

	# service theme files
	def file
		# FIXME
		f = File.join params[:filename]
		response.headers['Content-Type'] = MIME_TYPES[f[/\.\w+$/, 0]] or "text/plain"
		# prevent directory traversal attacks
		path = File.join(Rails.root, THEME_ROOT, @theme_name, f)
		if (not f.include?("..")) and File.exist? path
			response.headers['X-Sendfile'] = path
			render :file => path, :template => false, :layout => false
		else
			render :status => 403, :template => false, :layout => false, :text => "403 - Invalid path"
		end
	end

end
