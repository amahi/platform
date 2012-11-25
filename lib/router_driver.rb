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

# router interface library

require 'pluginfactory'


class RouterDriver
	include PluginFactory

	AMAHI_ROUTER_PLUGINS = File.join(Rails.root, 'amahi-plugins/routers')

	@@router = nil
	# dummy mode - calls to do_get or do_post go down the bit bucket
	@@dummy_mode = false
	# authentication settings - default to something remotely sane
	@@auth = { :user => Setting.get('router_username') || 'admin', :password => Setting.get('router_password') || 'admin' }

	def self::derivativeDirs
		[AMAHI_ROUTER_PLUGINS]
	end

	def self.current_router
		@@router
	end

	def self.current_router=(classname)
		@@router = nil
		return if classname.blank?
		return if classname == "-"

		# if it looks like a class name, load the drivers
		self.load_router_drivers
		# save it as a class from the class name
		begin
			@@router = eval classname
		rescue
			@@router = nil
		end
	end

	def self.dummy_mode=(is_dummy)
		@@dummy_mode=id_dummy
	end

	def self.load_router_drivers
		Dir["#{AMAHI_ROUTER_PLUGINS}/*.rb"].each{ |x| require x }
		derivativeClasses
	end

	def self.available_drivers
		self.load_router_drivers
	end

	def self.url_encode(url)
		URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
	end

	def self.do_get(url)
		#puts "URL: '#{url}'"
		return if @@dummy_mode
		res = Net::HTTP.get_response(URI.parse(url))
		raise "Error #{FILE} could not get '#{url}'!" unless res != Net::HTTPSuccess
	end

	def self.do_post(url, form, return_msg="")
		return if @@dummy_mode
		uri = URI.parse(url)
		req = Net::HTTP::Post.new(uri.path)
		req.basic_auth(@@auth[:user] || '', @@auth[:password] || '') if @@auth[:password]
		req.set_form_data(form)
		# puts "***************      POST URL(u:#{@@auth[:user]}, p:#{ @@auth[:password]}): '#{url}'"
		# puts "***************      FORM: #{form.inspect}"
		res = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }
		res.body
		passed = res.body =~ Regexp.new(return_msg, Regexp::MULTILINE)
		if RAILS_DEFAULT_LOGGER and ((res == Net::HTTPSuccess) or not passed)
			RAILS_DEFAULT_LOGGER.error("*************** DEBUG BEGIN - The router/fw returned this:")
			RAILS_DEFAULT_LOGGER.error("#{res.body.inspect}")
			RAILS_DEFAULT_LOGGER.error("*************** DEBUG END")
		end
		raise "Error #{FILE} could not get '#{url}'!" unless res != Net::HTTPSuccess
		unless passed
			raise "Error: could not find '#{return_msg}' in the returned body!"
		end
	end

	def self.set_auth(user, password)
		@@auth[:user] = user if user
		@@auth[:password] = password if password
	end

	def self.auth
		@@auth
	end

	def self.username
		@@auth[:user]
	end

	def self.password
		@@auth[:password]
	end

	def self.supports?(feature)
		self.support.include? feature
	end
end
