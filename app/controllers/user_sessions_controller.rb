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

class UserSessionsController < ApplicationController
	before_filter :login_required, :except => ['new', 'create', 'set_first_password']
	layout 'login'

	def new
		@user_session = UserSession.new
	end

	def create
		username = params[:username]
		password = params[:password]
		remember_me = params[:remember_me]
		@user = User.find_by_login username
		if @user == nil
			(name, uid) = User.system_find_name_by_username(username)
			# FIXME-cpg: hackish fedora constant for regular uid (500)
			if name and uid and uid >= 500
				@user = User.new(:login => username, :name => name)
				# empty user without password created!
				@user.save :validate => false
				# fall through to new user below
			else
				flash[:error] = t 'not_a_valid_user_or_password'
				@user_session = UserSession.new
				render :action => 'new'
				return
			end
		end
		if @user && @user.needs_auth? and User.admins.count == 0
			# FIXME-translate
			flash[:notice] = t('first_time_admin_setup')
			render :action => :first_password
			return
		end
		@user_session = UserSession.new(:login => username, :password => password, :remember_me => remember_me)
		if @user_session.save
			redirect_to root_url
		else
			flash[:error] = t 'not_a_valid_user_or_password'
			render :action => 'new'
		end
	end

	def destroy
		@user_session = UserSession.find
		@user_session.destroy
		# FIXME-translate
		flash[:notice] = t('you_have_been_logged_out')
		redirect_to root_path
	end

	def set_first_password
		pwd = params[:password]
		conf = params[:password_confirmation]
		unless valid_admin_password?(pwd, conf)
			flash[:error] = t 'not_a_valid_user_or_password'
			@user = User.find_by_login params[:username]
			sleep 1
			redirect_to new_user_session_url
			return
		end
		u = User.find_by_login params[:username]
		unless u.needs_auth? and User.admins.count == 0
			flash[:error] = t 'not_a_valid_user_or_password'
			sleep 1
			redirect_to new_user_session_url
			return
		end
		u.update_attributes(:password => pwd, :password_confirmation => conf, :admin => true)
		u.add_to_users_group
		u.add_or_passwd_change_samba_user
		flash[:notice] = t 'admin_setup_worked'
		UserSession.create(u, true)
		# create the initial server structures
		Server.create_default_servers if Server.count < 4
		redirect_to root_url
	end


private

	def allow_root_access?
		User.all.each do |u|
			return false if u.crypted_password and not u.crypted_password.blank?
		end
		true
	end

	# FIXME: this is busted! PAM will not authenticate other
	# than the caller's user (apache)!
	# we would need to do our own authentication solution!
	def valid_system_credentials?(user, password)
		User.valid_pam_auth?(user, password)
	end

	# for admins, slightly stronger password, by length
	# FIXME - strength
	def valid_admin_password?(pwd, conf)
		return false if pwd.nil? or pwd.blank?
		return true if conf.size > 4 and pwd == conf
		false
	end

end
