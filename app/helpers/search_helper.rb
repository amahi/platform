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

module SearchHelper

	EXT2ICON = {	'photo'   => 'jpg|png|tiff|tif|jpeg',
			'image'   => 'gif|bmp|ico|drw|3dm|3dmf|dxf|mng|pct|psp|svg|thm',
			'music'   => 'wav|mid|midi',
			'audio'   => 'mp3|ogg|flac|aac|aif|iff|m4a|mpa|ra|wma|ram|m3u',
			'movie'   => 'vob|mp4|mkv|3g2|3gp|asf|asx|avi|flv|mov|mpg|mpeg|qt|rm|wmv',
			'archive' => 'zip|tar.gz|tgz|tar.bz2|par2|par',
			'rar'     => 'rar',
			'pdf'     => 'pdf|eps|ps',
			'aex'     => 'aex',
			'doc'     => 'doc|docx|odt',
			'xls'     => 'xls|xlsx',
			'ppt'     => 'ppt|pptx',
			'xml'     => 'xml|xhtml',
			'html'    => 'html|htm',
			'swf'     => 'swf',
			'ai'      => 'ai',
			'fla'     => 'fla',
			'iso'     => 'iso|img',
			'maya'    => 'mb|ma|obj',
			'jar'     => 'jar',
			'hdr'     => 'hdr',
			'max'     => 'max',
			'php'     => 'php',
			'psd'     => 'psd|ai',
			'exe'     => 'exe|com',
			'ocd'     => 'ocd',
			'xfl'     => 'xfl',
			'text'    => 'txt'	}
			# default is 'text'

	def file_type_to_icon(type, path)
		return theme_image_tag(File.join('icons', 'folder.png')) if type == 'directory'
		return theme_image_tag(File.join('icons', extmatch(File.extname(path))))
	end

protected

	def extmatch(ext)
		EXT2ICON.each_pair do |type, regexp|
			return "#{type}.png" if ext =~ /\.(#{regexp})$/i
		end
		# default
		return 'text.png'
	end

	# for testing:
	#
	# 	define EXT2ICON
	# 	require 'fileutils'
	# 	make_extensions_test_folder
	# 	sudo updatedb &
	# 	locate extension-test
	# 	rm -rf /var/hda/files/docs/extension-test
	#
	def make_extensions_test_folder
		Dir.chdir(Share.full_path('docs')) do
			FileUtils.mkdir_p "extension-test"
			Dir.chdir "extension-test"
			EXT2ICON.each_pair do |type, regexp|
				all = regexp.split '|'
				all.each { |e| system "touch", "test.#{e}" }
			end
		end
	end

end
