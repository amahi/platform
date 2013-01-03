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

require 'router_driver'

class FirewallController < ApplicationController
	before_filter :admin_required
	before_filter :setup_router

	MAC_P = '(\d|[A-Fa-f])(\d|[A-Fa-f])'

	def new_rule_type
		rule = params[:rule]
		@net = Setting.get 'net'
		case rule
		when 'port_filter'
			render :partial => 'fields_port_filter'
		when 'url_filter'
			render :partial => 'fields_url_filter'
		when 'mac_filter'
			render :partial => 'fields_mac_filter'
		when 'ip_filter'
			render :partial => 'fields_ip_filter'
		when 'port_forward'
			render :partial => 'fields_port_forward'
		else
			# raise "error - handling '#{rule}' is not done yet"
			render :partial => 'empty_select'
		end
	end

	def create
		rule = params[:rule]
		f = Firewall.new(:kind => rule, :comment => params[:comment])
		case rule
		when 'port_filter'
			f.protocol = params[:protocol]
			f.range = params[:range_lo] + "-" + params[:range_hi]
		when "ip_filter"
			f.ip = params[:ip]
			f.protocol = params[:protocol]
		when 'mac_filter'
			f.mac = params[:mac]
		when 'port_forward'
			f.ip = params[:ip]
			f.protocol = params[:protocol]
			f.range = params[:range_lo] + "-" + params[:range_hi]
		when 'url_filter'
			f.url = params[:url]
		else
			raise "cannot handle fw rule '#{rule}'"
		end
		f.state = Setting.get(rule) == "1"
		f.save!
		@net = Setting.get 'net'
		render :partial => "body", :locals => { :fw_rules => Firewall.find(:all) }
	end

	def delete
		id = params[:id]
		fw = Firewall.find id
		# FIXME  index = Firewall.by_date
		# fw.delete_rule(index)
		fw.destroy
		@net = Setting.get 'net'
		render :partial => "list", :locals => { :fw_rules => Firewall.find(:all) }
	end

	def check_port_range_hi
		lo = params[:range_lo]
		hi = params[:range_hi]
		valid, message = valid_range?(lo, hi)
		if valid
			render :partial => "port_range_good", :locals => { :message => message }
		else
			render :partial => "port_range_bad", :locals => { :message => message }
		end
	end

	def check_port_range_lo
		lo = params[:range_lo]
		hi = params[:range_hi]
		valid, message = valid_range?(lo, hi)
		if lo.blank? or hi.blank?
			render :text => ""
		elsif valid
			render :partial => "port_range_good", :locals => { :message => message }
		else
			render :partial => "port_range_bad", :locals => { :message => message }
		end
	end

	def check_ip
		ip = params[:ip]
		# FIXME - this will need to check for other
		# things like not being the HDA ip (perhaps), etc.
		# it also needs to NOT enable the create button if the
		# context is port forwarding!
		if ip.blank?
			render :partial => "ip_bad", :locals => { :message => t('the_ip_address_cannot_be_empty') }
		elsif ip.to_i < 1 or ip.to_i > 254
			render :partial => "ip_bad", :locals => { :message => t('the_ip_must_be_1_to_254') }
		else
			render :partial => "ip_good", :locals => { :message => t('the_ip_looks good') }
		end
	end

	def check_mac
		mac = params[:mac]
		if valid_mac? mac
			render :partial => "mac_good", :locals => { :message => t('the_mac_looks_good') }
		else
			render :partial => "mac_bad", :locals => { :message => t('the_mac_is_invalid') }
		end
	end

	def check_url
		url = params[:url]
		url.strip!
		if url.blank? or not url =~ /^http:\/\//
			render :partial => "url_bad", :locals => { :message => t('the_url_is_invalid') }
		else
			render :partial => "url_good", :locals => { :message => t('the_url_looks_good') }
		end
	end

protected

	def valid_range?(lo, hi)
		ret = [false]
		return ret << t('port_range_field_cannot_be_empty') if lo.blank? or hi.blank?
		return ret << t('port_range_ports_must_be_numbers')  unless (lo + hi) =~ /^[0-9]+$/
		lo = lo.to_i
		hi = hi.to_i
		return ret << t('port_range_ports_must_be_0_to_64k') if lo < 1 or hi > 65535
		return ret << t('port_range_ports_must_be_increasing_order') if lo > hi
		Firewall.port_forwards.each do |rule|
		 	l, h = rule.range.split '-'
			l = l.to_i
			h = h.to_i
			ret << t('port_range_ports_are_already_allocated')
			return ret if l >= lo and l <= hi
			return ret if h >= lo and h <= hi
			return ret if l < lo and h > hi
		end
		[true, t('port_range_looks_good')]
	end

	def valid_mac?(mac)
		m = [MAC_P, MAC_P, MAC_P, MAC_P, MAC_P, MAC_P].join ':'
		valid_mac = Regexp.new m
		return false unless (mac =~ valid_mac)
		true
	end

	def setup_router
		r = Setting.get_kind('network', 'router_model')
		RouterDriver.current_router = r ? r.value : ""
	end
end
