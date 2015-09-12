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

require "open3"

class SharesController < ApplicationController

	before_filter :admin_required

	before_filter :get_share

	def index
		@page_title = t('shares')
		get_shares
	end

	def create
		sleep 2 if development?
		params[:share][:path] = Share.default_full_path(params[:share][:name])
		@share = Share.new(params[:share])
		@share.save
		get_shares unless @share.errors.any?
	end

	def destroy
		sleep 2 if development?
		@share.destroy
		render :json => { :status=> :ok,:id => @share.id }
	end

	def settings
		unless @advanced
			redirect_to shares_engine_path
		else
			@page_title = t('shares')
			@workgroup = Setting.find_or_create_by(Setting::GENERAL, 'workgroup', 'WORKGROUP')
		end
	end

	def toggle_visible
		sleep 2 if development?
		@saved = @share.toggle_visible! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_everyone
		sleep 2 if development?
		@saved = @share.toggle_everyone! if @share
		render_share_access
	end

	def toggle_readonly
		sleep 2 if development?
		@saved = @share.toggle_readonly! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_access
		sleep 2 if development?
		@saved = @share.toggle_access!(params[:user_id]) if @share
		render_share_access
	end

	def toggle_write
		sleep 2 if development?
		@saved = @share.toggle_write!(params[:user_id]) if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def toggle_guest_access
		sleep 2 if development?
		@saved = @share.toggle_guest_access! if @share
		render_share_access
	end

	def toggle_guest_writeable
		sleep 2 if development?
		@saved = @share.toggle_guest_writeable! if @share
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_tags
		sleep 2 if development?
		@saved = @share.update_tags!(params)
	end

	def update_path
		sleep 2 if development?
		@saved = @share.update_tags!(params)
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_workgroup
		sleep 2 if development?
		@workgroup = Setting.find(params[:id]) if params[:id]
		if @workgroup && @workgroup.name.eql?("workgroup")
			params[:share][:value].strip!
			@saved = @workgroup.update_attributes(params[:share])
			@errors = @workgroup.errors.full_messages.join(', ') unless @saved
			name = @workgroup.value
			Share.push_shares
		end
		render :json => { :status => @saved ? :ok : :not_acceptable, :message => @saved ? t('workgroup_changed_successfully') : t('error_occured'), :name => name }
	end

	def update_extras
		sleep 2 if development?
		params[:share] = sanitize_text(params[:share])
		@saved = @share.update_extras!(params)
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def clear_permissions
		@share = Share.find(params[:id]) if params[:id]
		sleep 2 if development?
		if @share
			@cleared = @share.clear_permissions
			render :json => { :status => :ok }
		else
			render :json => { :status => :not_acceptable }
		end
	end

	def update_size
		sleep 1 if development?
		begin
			std_out, status = Open3.capture2e("du -sbL #{@share.path}")
			size = std_out.split(' ').first
			is_integer = Integer(size) != nil rescue false
			if is_integer and status
				helper = Object.new.extend(ActionView::Helpers::NumberHelper)
				size = helper.number_to_human_size(size)
			else
				size = std_out
			end
		rescue Exception => e
			size = e.to_s
		end
		render :json => { status: :ok, size: size, id: @share.id }
	end

	protected

	def render_share_access
		render :json => render_to_string('shares/_access') and return
	end

	def get_share
		@share = Share.find(params[:id]) if params[:id]
	rescue
	end

	def get_shares
		@shares = Share.all
	end

end
