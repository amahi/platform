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

	before_action :admin_required
	before_action :no_subtabs

	helper_method :can_i_toggle_admin?

	def index
		@page_title = t('users')
		@users = User.all_users
	end

	def create
		sleep 2 if development?
		@user = User.new(permitted_params.permit)
		@user.save
		@users = User.all_users unless @user.errors.any?
	end

	def update
		sleep 2 if development?
		name = permitted_params.permit[:name]
		id = permitted_params.permit[:id]
		user = User.find id
		if can_i_edit_details?(user)
			if(name.strip.length !=0)
				user.name = name
				user.save!
				name = user.name
				errors = user.errors.any? ? user.error.full_messages.join(', ') : false
			else
				errors = t('the_name_cannot_be_blank')
			end
		else
			errors = t('dont_have_permissions')
		end
		render :json => { :status => errors ? :not_acceptable : :ok , :message => errors ? errors : t('name_changed_successfully') , :name=> name, :id=> id }
	end

	def update_pubkey
		sleep 2 if development?
		@user = User.find(permitted_params.permit[:id])
		# sleep a little to see the spinner working well
		unless @user
			render :json => { :status => :not_acceptable }
		else
			key = permitted_params.permit["public_key_#{permitted_params.permit[:id]}"]
			key = nil if key.blank?
			@user.public_key=key
			@user.save
			render :json => { :status => @user.errors.empty? ? :ok : { :messages => @user.errors.full_messages } }
		end
	end

	def destroy
		sleep 2 if development?
		@user = User.find(permitted_params.permit[:id])
		id = nil
		if @user && @user != current_user && !@user.admin?
			@user.destroy
			id = @user.id unless @user.errors.any?
			render :json => { :status => id==nil ? t('error_occured') : :ok, :id => id }
		else
		render :json => { status: 'not_acceptable' , id: id }
		end
	end

	def toggle_admin
		sleep 2 if development?
		user = User.find permitted_params.permit[:id]
		if can_i_toggle_admin?(user)
			user.admin = !user.admin
			user.save!
			@saved = true
		end
		render :json => { :status => @saved ? :ok : :not_acceptable }
	end

	def update_password
		sleep 2 if development?
		@user = User.find(permitted_params.permit[:id])
		if(permitted_params.permit[:password].blank? || permitted_params.permit[:password_confirmation].blank?)
			errors = true
			error = t("password_cannot_be_blank")
		else
			@user.update_attributes(permitted_params.permit)
			errors = @user.errors.any?
			error = @user.errors.full_messages.join(', ')
		end
		render :json => { :status => errors ? :not_acceptable : :ok, :message => errors ?  error : t('password_changed_successfully') }
	end

	def update_name
		@user = User.find(permitted_params.permit[:id])
		@user.update_attributes(permitted_params.permit)
		render :json => { :status => @user.errors.any? ? :not_acceptable : :ok }
	end

	def settings
		unless @advanced
			redirect_to users_engine_path
		end
	end

	protected

	def can_i_toggle_admin?(user)
		current_user != user and !user.needs_auth?
	end

	def can_i_edit_details?(user)
		(current_user == user || current_user.admin?)
	end

end
