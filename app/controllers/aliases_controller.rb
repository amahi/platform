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

class AliasesController < ApplicationController

	before_filter :admin_required

	VALID_NAME = Regexp.new "\A[A-Za-z0-9\-]+\z"
	VALID_ADDRESS = Regexp.new '\A(|\d(\d?\d?)|\d(\d?\d?)\.\d(\d?\d?)\.\d(\d?\d?)\.\d(\d?\d?))\z'

	def initialize
	      @page_title = 'DNS Aliases'
	end

	# GET /aliases
	# GET /aliases.xml
	def index
	  @aliases = DnsAlias.find(:all)

	  respond_to do |format|
	    format.html # index.html.erb
	    format.xml  { render :xml => @aliases }
	  end
	end

	# GET /aliases/1
	# GET /aliases/1.xml
	def show
	  @alias = DnsAlias.find(params[:id])

	  respond_to do |format|
	    format.html # show.html.erb
	    format.xml  { render :xml => @alias }
	  end
	end

	# GET /aliases/new
	# GET /aliases/new.xml
	def new
	  @alias = DnsAlias.new

	  respond_to do |format|
	    format.html # new.html.erb
	    format.xml  { render :xml => @alias }
	  end
	end

	# GET /aliases/1/edit
	def edit
	  @alias = DnsAlias.find(params[:id])
	  @net = Setting.get 'net'
	end

	# POST /aliases
	# POST /aliases.xml - FIXME
	def create
	  @alias = DnsAlias.new(params[:alias])

	  respond_to do |format|
	    if @alias.save
	      format.html do
			@net = Setting.get('net')
			@domain = Setting.get('domain')
			@self = [@net, Setting.get('self-address')].join '.'
			render :partial => "aliases/index", :locals => { :aliases => DnsAlias.user_visible }
		end
	      format.xml  { render :xml => @alias, :status => :created, :location => @alias }
	    else
	      format.html { raise "could not save #{params.inspect}" }
	      format.xml  { render :xml => @alias.errors, :status => :unprocessable_entity }
	    end
	  end
	end

	# PUT /aliases/1
	# PUT /aliases/1.xml
	def update
	  @alias = DnsAlias.find(params[:id])

	  respond_to do |format|
	    if @alias.update_attributes(params[:alias])
	      flash[:notice] = 'Alias was successfully updated.'
	      format.html { redirect_to(@alias) }
	      format.xml  { head :ok }
	    else
	      format.html { render :action => "edit" }
	      format.xml  { render :xml => @alias.errors, :status => :unprocessable_entity }
	    end
	  end
	end

	# DELETE /aliases/1
	# DELETE /aliases/1.xml
	def destroy
	  @alias = DnsAlias.find(params[:id])
	  @alias.destroy

	  respond_to do |format|
	    format.html { redirect_to(aliases_url) }
	    format.xml  { head :ok }
	  end
	end

	def update_address
		a = DnsAlias.find(params[:id])
		addr = params[:value].strip
		# FIXME - report errors to the user!
		unless valid_address?(addr)
			render :text => a.address
			return
		end
		if ((valid_short_address?(a.address) and not valid_short_address?(addr)) or
			(is_address_full?(a.address) and not is_address_full?(addr)))
			render :text => a.address
			return
		end
		a.address = addr
		a.save
		a.reload
		if a.address.blank?
			render :text => "(hda)"
			return
		end
		render :text => a.address
	end


	def delete
		a = DnsAlias.find params[:id]
		a.destroy
		aliases = DnsAlias.user_visible
		@net = Setting.get('net')
		@domain = Setting.get('domain')
		@self = [@net, Setting.get('self-address')].join '.'
		render :partial => 'aliases/list', :locals => { :aliases => aliases }
	end


	def new_alias_check
		n = params[:alias]
		if n.nil? or n.blank?
			render :partial => 'aliases/name_bad'
			return
		end
		n = n.strip
		if (not (valid_name?(n))) or (n.size > 32)
			render :partial => 'aliases/name_bad'
			return
		end
		a = DnsAlias.where(:alias=>n).first
		if a.nil?
			# no such alias, ok to create it
			@name = n
			render :partial => 'aliases/name_available'
		else
			render :partial => 'aliases/name_unavailable'
		end
	end

	def new_address_check
		n = params[:address]
		n = '' if n.nil? or n.blank?
		n = n.strip
		if (not (valid_address?(n))) or (n.size > 28)
			render :partial => 'aliases/address_bad'
			return
		end
		render :partial => 'aliases/address_available'
	end

private

	# FIXME-cpg: some of this should probably be in the model for aliases

	def valid_name?(nm)
		return false unless (nm =~ VALID_NAME)
		true
	end

	def valid_address?(addr)
		return false if addr.nil?
		# NOTE: do not allow aliases to the hda as a blank address
		return false if addr.blank?
		return false unless (addr =~ VALID_ADDRESS)
		if addr =~ Regexp.new('\A(\d+)\.(\d+)\.(\d+)\.(\d+)\z')
			[$1, $2, $3, $4].each { |ip| return false if ip.to_i > 254 }
			return true
		end
		valid_short_address?(addr)
	end

	def is_address_full?(addr)
		(addr =~ Regexp.new('\A(\d+)\.(\d+)\.(\d+)\.(\d+)\z')) ? true : false
	end

	def valid_short_address?(addr)
		if addr =~ Regexp.new('\A(\d+)\z')
			v = addr.to_i
			return true unless v < 0 or v > 254
		end
		false
	end
end
