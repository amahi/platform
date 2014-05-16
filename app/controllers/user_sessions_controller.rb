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
	before_filter :login_required, :except => ['new', 'create', 'start', 'initialize_system']
	layout 'login'

	def new
		if initialized?
			@user_session = UserSession.new
		else
			# if the system is not initialized, start by doing that
			redirect_to start_path
		end
	end

	def start
		if initialized?
			# if the system is initialized already, go to login
			redirect_to login_path
		else
			# initial system initialization
			@user = User.new
			flash[:notice] = t("amahi_initialization")
			@title = t("amahi_initialization")
		end
	end

	def create
		username = params[:username]
		password = params[:password]
		remember_me = params[:remember_me]
		@user_session = UserSession.new(:login => username, :password => password, :remember_me => remember_me)
		if @user_session.save
			redirect_to root_url
		else
			flash[:error] = t 'not_a_valid_user_or_password'
			render :action => 'new'
		end
	end

	# logout - destroy the user session
	def destroy
		@user_session = UserSession.find
		@user_session.destroy
		# FIXME-translate
		flash[:notice] = t('you_have_been_logged_out')
		redirect_to root_path
	end

	# initialize the system all in one shot
	def initialize_system
		username = params[:username]
		pwd = params[:password]
		conf = params[:password_confirmation]
		unless valid_admin_password?(pwd, conf)
			flash[:error] = t 'not_a_valid_user_or_password'
			@user = User.new
			sleep 1
			render :action => 'start'
			return
		end

		# here we have a possible user: new in the system (truly new or the user may have
		# mistyped a username?), or an old user
		(name, uid, systemusername) = User.system_find_name_by_username(username)
		# FIXME-cpg: very hackish constant for regular uid (1000)
		unless name and uid and uid >= 1000
			# not a system user. should we create one?
			flash[:error] = t 'not_a_valid_user_or_password'
			@user = User.new
			render :action => 'start'
			return
		end
		# the user exists in the system .. does it exist in the database?
		u = User.where(:login=>systemusername).first
		if u
			@user = u
		else
			@user = User.new(:login => systemusername, :name => name, :password => pwd, :password_confirmation => conf, :admin => true)
			@user.save(:validate => false)
			@user.add_to_users_group
			@user.add_or_passwd_change_samba_user
		end
		# ok we have a user, it's in the system ... start a session for it
		@user_session = UserSession.new(:login => username, :password => pwd)
		if @user_session.save
			# create the initial server structures
			initialize_default_settings
			redirect_to root_url
		else
			flash[:error] = t 'not_a_valid_user_or_password'
			render :action => 'start'
		end
	end


private

	# initialize various one-time default settings
	def initialize_default_settings
		return if initialized?
		# general settings
		Setting.set('advanced', '0')
		Server.create_default_servers if Server.count < 4
		Setting.set('guest-dashboard', '0')
		Setting.set('theme', 'default')
		# network settings
		network = Setting::NETWORK
		Setting.find_or_create_by(network, 'dns', 'opennic')
		Setting.find_or_create_by(network, 'dns_ip_1', '173.230.156.28')
		Setting.find_or_create_by(network, 'dns_ip_2', '23.90.4.6')
		Setting.find_or_create_by(network, 'dnsmasq_dhcp', '1')
		Setting.find_or_create_by(network, 'dnsmasq_dns', '1')
		Setting.find_or_create_by(network, 'lease_time', '14400')
		Share.create_default_shares if Rails.env == "production"
		# set it to initialized and go!
		Setting.set('initialized', '1')
	end

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

	def initialized?
		Setting.get('initialized') && Setting.get('initialized') == '1'
	end

end
