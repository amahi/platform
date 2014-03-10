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

require 'rubygems'
require 'active_support/all'
require 'active_resource'

# Ruby lib for working with the Amahi API's REST interface.
#
# The first thing you need to set is the api key.  This is the
# settings in your HDA
#
#    AmahiApi.api_key = 'abcxyz123'
#
# This library is a small wrapper around the REST interface for
# Amahi.
#
# You should read the (admittedly spare) docs at
# http://wiki.amahi.org/index.php/API

module AmahiApi
	class Error < StandardError; end
	class << self
		attr_accessor :host_format, :domain_format, :protocol
		attr_reader :api_key

		# Sets the API api_key for all the resources.
		def api_key=(value)
			resources.each do |klass|
				klass.site = klass.site_format % (host_format % [protocol, domain_format])
				klass.headers['X-AmahiApiKey'] = value
			end
			@api_key = value
		end

		def resources
			@resources ||= []
		end
	end

	self.host_format   = '%s://%s'
	self.domain_format = 'api.amahi.org/api2'
	self.protocol      = 'https'

	class Base < ActiveResource::Base
		def self.inherited(base)
			AmahiApi.resources << base
			class << base
				attr_accessor :site_format
			end
			base.site_format = '%s'
			super
		end
	end

	# Create Error Reports
	#
	#   er = AmahiApi::ErrorReport.new(:report => "the whole shebang")
	#   er.save
	#   # => should return true
	#
	class ErrorReport < Base
	end

	# Retrive Apps
	#
	#   a = AmahiApi::App.find appid
	#   # => should return the app info
	#
	class App < Base
	end

	# AppInstaller
	#
	#   a = AmahiApi::AppInstaller.find appid
	#   # => should return the app installation details
	#
	class AppInstaller < Base
	end

	# AppUnInstaller
	#
	#   a = AmahiApi::AppUnInstaller.find appid
	#   # => should return the app uninstallation details
	#
	class AppUninstaller < Base
	end

	class TimelineEvent < Base
	end

end
