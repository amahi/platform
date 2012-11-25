# Amahi Home Server
# Copyright (C) 2007-2010 Amahi
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

module ShareHelper

	# put up warnings for / and /media mounts
	def optional_warnings(path)
		url = nil
		wiki = "http://wiki.amahi.org/index.php"
		# warning for /media _disk_pooling_partition_checkbox.html.erb - see bug #616
		if path == '/'
			url = link_to(theme_image_tag("more", :title => 'Greyhole not on root'), "#{wiki}/Greyhole_not_on_root")
		elsif path =~ /^\/media/
			url = link_to(theme_image_tag("more", :title => 'Greyhole not on /media'), "#{wiki}/Greyhole#.2Fmedia")
		end
		return "" unless url
		url = theme_image_tag("danger") + " &raquo; " + url
		"<span style=\"float: right\">#{url}</span>"
	end
end
