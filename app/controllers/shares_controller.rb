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

class SharesController < ApplicationController

	before_filter :admin_required

	before_filter :create_default
	before_filter :get_share

	def index
		@page_title = t('shares')
		get_shares
	end

	def create
		@share = Share.new(params[:share])
		@share.save
		get_shares unless @share.errors.any?
	end

	def destroy
		@share.destroy
		render :json => { :id => @share.id }
	end

	def disk_pooling
		@page_title = t('shares')
		@partitions = PartitionUtils.new.info.delete_if { |p| p[:bytes_free] < 200.megabytes and not DiskPoolPartition.find_by_path(p[:path]) }
		@broken_partitions = DiskPoolPartition.all.delete_if { |dpp| ! @partitions.select{|p| p[:path] == dpp.path}.empty? }
	end

	def settings
		@page_title = t('shares')
	end

	def toggle_visible
		@saved = @share.toggle_visible! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_everyone
		@saved = @share.toggle_everyone! if @share
		render_share_access
	end

	def toggle_readonly
		@saved = @share.toggle_readonly! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_access
		@saved = @share.toggle_access!(params[:user_id]) if @share
		render_share_access
	end

	def toggle_write
		@saved = @share.toggle_write!(params[:user_id]) if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_guest_access
		@saved = @share.toggle_guest_access! if @share
		render_share_access
	end

	def toggle_guest_writeable
		@saved = @share.toggle_guest_writeable! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_tags
		@saved = @share.update_tags!(params)
	end

	def update_path
		@saved = @share.update_tags!(params)
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_disk_pool
		@saved = @share.toggle_disk_pool!
	end

	def update_disk_pool_copies
		@saved = @share.update_disk_pool_copies!(params)
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_extras
		@saved = @share.update_extras!(params)
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_disk_pool_partition
		render :json => { :force => DiskPoolPartition.toggle_disk_pool_partition!(params[:path]) }
	end

	def clear_permissions
		@share = Share.find(params[:id]) if params[:id]
		if @share
			@cleared = @share.clear_permissions
			render :json => { :status => :ok }
		else
			render :json => { :status => :not_acceptable }
		end
	end


	protected

	def render_share_access
		render :json => render_to_string('shares/_access') and return
	end

	def create_default
		Share.create_default_shares if Share.count == 0
	end

	def get_share
		@share = Share.find(params[:id]) if params[:id]
	rescue
	end

	def get_shares
		@shares = Share.all
	end

	#@page_title = t 'shares'
	#@shares = Share.all.sort { |x,y| x.name.casecmp y.name }
	#@debug = Setting.shares.f('debug')
	#@pdc = Setting.shares.f('pdc')
	#@workgroup = Setting.shares.f('workgroup')
	#@win98 = Setting.shares.f('win98')
	## do not show if there little free space (unless it's already in the pool! maybe it got full)
	## note: the 200mb cuts out the default /boot partition
	#@partitions = PartitionUtils.new.info.delete_if { |p| p[:bytes_free] < 200.megabytes and not DiskPoolPartition.find_by_path(p[:path]) }
	#@broken_disk_pool_partitions = DiskPoolPartition.all.delete_if { |dpp| ! @partitions.select{|p| p[:path] == dpp.path}.empty? }

end
