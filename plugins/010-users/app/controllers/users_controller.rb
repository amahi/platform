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

class UsersController < ApplicationController

	before_filter :admin_required
	before_filter :no_subtabs

	helper_method :can_i_toggle_admin?

	def index
		@page_title = t('users')
		@users = User.all_users
	end

	def create
		sleep 2 if development?
		@user = User.new(params[:user])
		@user.save
		@users = User.all_users unless @user.errors.any?
	end

	def update
	end

	def update_pubkey
		sleep 2 if development?
		@user = User.find(params[:id])
		# sleep a little to see the spinner working well
		unless @user
			render :json => { :status => :not_acceptable }
		else
			key = params["public_key_#{params[:id]}"]
			key = nil if key.blank?
			@user.public_key=key
			@user.save
			render :json => { :status => @user.errors.empty? ? :ok : { :messages => @user.errors.full_messages } }
		end
	end

	def destroy
		sleep 2 if development?
		@user = User.find(params[:id])
		id = nil
		if @user && @user != current_user && !@user.admin?
			@user.destroy
			id = @user.id unless @user.errors.any?
			render :json => { :status 	=> id ? :error_occured : :ok, :id => id }
		end
		render :json => { status: 'not_acceptable' , id: id }
	end

	def toggle_admin
		sleep 2 if development?
		user = User.find params[:id]
		if can_i_toggle_admin?(user)
			user.admin = !user.admin
			user.save!
			@saved = true
		end
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_password
		sleep 2 if development?
		@user = User.find(params[:id])
		@user.update_attributes(params[:user])
		errors = @user.errors.any?
		render :json => { :status => errors ? :not_acceptable : :ok,
			:message => errors ? @user.errors.full_messages.join(', ') : t('password_changed_successfully') }
	end

	def update_name
		@user = User.find(params[:id])
		@user.update_attributes(params[:user])
		render :json => { :status => @user.errors.any? ? :not_acceptable : :ok }
	end

	protected

	def can_i_toggle_admin?(user)
		current_user != user and !user.needs_auth?
	end

end
