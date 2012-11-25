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

class HostsController < ApplicationController
	before_filter :admin_required

	VALID_NAME = Regexp.new "^[A-Za-z][A-Za-z0-9\-]+$"
	VALID_ADDRESS = Regexp.new '^(|\d(\d?\d?)|\d(\d?\d?)\.\d(\d?\d?)\.\d(\d?\d?)\.\d(\d?\d?))$'
	MAC_P = '(\d|[A-Fa-f])(\d|[A-Fa-f])'
	# This is the range at which DHCP starts. Strictly below is valid

	# GET /hosts
	# GET /hosts.xml
	def index
	  @page_title = 'Static IP Addresses'
	  @hosts = Host.find(:all)
	  @max = VALID_DHCP_ADDRESS_RANGE-1 

	  respond_to do |format|
	    format.html # index.html.erb
	    format.xml  { render :xml => @hosts }
	  end
	end

	# GET /hosts/1
	# GET /hosts/1.xml
	def show
	  @host = Host.find(params[:id])

	  respond_to do |format|
	    format.html # show.html.erb
	    format.xml  { render :xml => @host }
	  end
	end

	# GET /hosts/new
	# GET /hosts/new.xml
	def new
	  @host = Host.new

	  respond_to do |format|
	    format.html # new.html.erb
	    format.xml  { render :xml => @host }
	  end
	end

	# GET /hosts/1/edit
	def edit
	  @host = Host.find(params[:id])
	  @net = Setting.get 'net'
	end

	# POST /hosts
	# POST /hosts.xml
	def create
	  @host = Host.new(params[:host])
	  @domain = Setting.get 'domain'

	  respond_to do |format|
	    if @host.save
	      format.html do
	      		@net = Setting.get('net')
	      		@self = [@net, Setting.get('self-address')].join '.'
	      		render :partial => "hosts/index", :locals => { :hosts => Host.all }
	      	end
	      format.xml  { render :xml => @host, :status => :created, :location => @host }
	    else
	      format.html { render :action => "new" }
	      format.xml  { render :xml => @host.errors, :status => :unprocessable_entity }
	    end
	  end
	end

	# PUT /hosts/1
	# PUT /hosts/1.xml
	def update
	  @host = Host.find(params[:id])
	  @domain = Setting.get 'domain'

	  respond_to do |format|
	    if @host.update_attributes(params[:host])
	      flash[:notice] = 'Host was successfully updated.'
	      format.html { redirect_to(@host) }
	      format.xml  { head :ok }
	    else
	      format.html { render :action => "edit" }
	      format.xml  { render :xml => @host.errors, :status => :unprocessable_entity }
	    end
	  end
	end

	# DELETE /hosts/1
	# DELETE /hosts/1.xml
	def destroy
	  @host = Host.find(params[:id])
	  @host.destroy

	  respond_to do |format|
	    format.html { redirect_to(hosts_url) }
	    format.xml  { head :ok }
	  end
	end

	def update_address
		a = Host.find(params[:id])
		addr = params[:value].strip
		# FIXME - report errors to the user!
		unless valid_short_address?(addr)
			render :text => a.address
			return
		end
		h = Host.find_by_address addr
		if h.nil?
			# no such address, ok to use it
			a.address = addr
			a.save
			a.reload
		end
		render :text => a.address
	end

	def update_mac
		a = Host.find(params[:id])
		mac = params[:value].strip
		# FIXME - report errors to the user!
		unless valid_mac?(mac)
			render :text => a.mac
			return
		end
		h = Host.find_by_mac mac
		if h.nil?
			# no such address, ok to use it
			a.mac = mac
			a.save
			a.reload
		end
		render :text => a.mac
	end

	def delete
		a = Host.find params[:id]
		a.destroy
		hosts = Host.all
		@net = Setting.get('net')
		@domain = Setting.get('domain')
		@self = [@net, Setting.get('self-address')].join '.'
		render :partial => 'hosts/list', :locals => { :hosts => hosts }
	end


	def new_host_check
		n = params[:host]
		if n.nil? or n.blank?
			render :partial => 'hosts/name_bad'
			return
		end
		n = n.strip
		if (not (valid_name?(n))) or (n.size > 32)
			render :partial => 'hosts/name_bad'
			return
		end
		a = Host.find_by_host(n)
		if a.nil?
			# no such alias, ok to create it
			@name = n
			render :partial => 'hosts/name_available'
		else
			render :partial => 'hosts/name_unavailable'
		end
	end

	def new_address_check
		n = params[:address]
		n = '' if n.nil? or n.blank?
		n = n.strip
		unless valid_short_address?(n)
			render :partial => 'hosts/address_bad'
			return
		end
		a = Host.find_by_address(n)
		if a.nil?
			# no such address, ok to create it
			@name = n
			render :partial => 'hosts/address_available'
		else
			render :partial => 'hosts/address_unavailable'
		end
	end

	def new_mac_check
		n = params[:mac]
		n = '' if n.nil? or n.blank?
		n = n.strip
		if (not (valid_mac?(n))) or (n.size > 18)
			render :partial => 'hosts/mac_bad'
			return
		end
		a = Host.find_by_mac(n)
		if a.nil?
			# no such mac, ok to create it
			@name = n
			render :partial => 'hosts/mac_good'
		else
			render :partial => 'hosts/mac_unavailable'
		end
	end

	def wake_system
		@host = Host.find(params[:id])
		if @host
			system "wol #{@host.mac}"
		end
	end

	def wake_mac
		@mac = params[:mac]
		if @mac
			system "wol #{@mac}"
		end
	end

private

	# FIXME-cpg: some of this should probably be in the model for hosts

	def valid_name?(nm)
		return false unless (nm =~ VALID_NAME)
		true
	end

	def valid_short_address?(addr)
		if addr =~ Regexp.new('^(\d+)$')
			v = addr.to_i
			return true if v > 0 and v < VALID_DHCP_ADDRESS_RANGE
		end
		false
	end

	def valid_mac?(mac)
		m = [MAC_P, MAC_P, MAC_P, MAC_P, MAC_P, MAC_P].join ':'
		valid_mac = Regexp.new m
		return false unless (mac =~ valid_mac)
		true
	end

end
