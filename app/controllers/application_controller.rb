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

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# require 'set_theme'
require 'tab'

class ApplicationController < ActionController::Base
	require 'ipaddr'
	protect_from_forgery with: :exception

	theme :theme_resolver

	before_action :before_action_hook
	before_action :initialize_validators
	before_action :prepare_plugins
	before_action :accessed_from_ip

	helper_method :current_user

	def accessed_from_ip
		unless (IPAddr.new(request.host) rescue nil).nil?
			flash.now[:warn] = "Your client device is probably not using your HDA for DNS yet. We <a href='https://wiki.amahi.org/index.php/Transition_to_Amahi' target='_blank'>recommend the following</a> for best experience."
		end
	end

	def initialize_validators
		@validators_string = ''
	end

	def before_action_hook
		set_locale
		set_direction
		check_for_amahi_app
		# disable for now until we get new themes
		#prepare_theme
		adv = Setting.where(:name=>'advanced').first
		@advanced = adv && adv.value == '1'
	end

	def check_for_amahi_app
		server = request.env['SERVER_NAME']
		dom = Setting.get_by_name('domain')
		if server && server != 'hda' && server =~ /\A(.*)\.#{dom}\z/
			server = $1
		end
		if server && server != 'hda' && DnsAlias.where(:name=>server).first
			redirect_to "http://hda/hda_app_#{server}"
		end
	end

	def prepare_theme
		@theme = SetTheme.find
		theme @theme.path
	end

	class Helper
		include Singleton
		include ActionView::Helpers::NumberHelper
	end

	def number_helpers
		Helper.instance
	end

	def setup_router
		@router = nil
		r = Setting.get_kind('network', 'router_model')
		return @router unless r
		begin
			rd = RouterDriver.current_router = (r ? r.value : "")
			# return the class proper if valid
			@router = Kernel.const_get(rd) unless rd.blank?
			u = Setting.network.where(:name=>'router_username').first
			p = Setting.network.where(:name=>'router_password').first
			RouterDriver.set_auth(unobfuscate(u.value), unobfuscate(p.value)) if p and u and p.value and u.value
		rescue
			# shhh. comment out the rescue for debugging
		end
		@router
	end

	def locales_implemented
		Yetting.locales_implemented
	end

	# Sanitizes the String or a Hash by removing the
	# escape characters like ^M which is originated from
	# end-of-line on Windows platform.
	# Expects either a Hash or a String,
	# and returns the same
	def sanitize_text(arg)
		if arg.is_a? Hash
			Hash[arg.to_a.map do |x, y|
				[x, y.lines.map(&:chomp).join("\n")]
			end]
		else
			#arg is a String
			arg.lines.map(&:chomp).join("\n")
		end
	end

	private

	def set_locale

		preferred_locales = request.headers['HTTP_ACCEPT_LANGUAGE'].split(',').map { |locale| locale.split(';').first } rescue nil
		available_locales = I18n.available_locales
		default_locale = I18n.default_locale
		locale_from_params = params[:locale]

		I18n.locale = begin
			locale = preferred_locales.select { |locale| available_locales.include?(locale.to_sym) }
			default_locale = locale.empty? ? default_locale : locale.first

			# Allow a URL param to override everything else, for devel
			if locale_from_params
				if available_locales.include?(locale_from_params.to_sym)
					cookies['locale'] = { :value => locale_from_params, :expires => 1.year.from_now }
					locale_from_params.to_sym
				else
					cookies.delete 'locale'
					default_locale
				end
			elsif cookies['locale'] && available_locales.include?(cookies['locale'].to_sym)
				cookies['locale'].to_sym
			else
				cookies['locale'] = { :value => default_locale, :expires => 1.year.from_now }
				default_locale
			end
		rescue
			# if something happens (like a locale file renamed!?) go back to the default
			default_locale
		end
	end

	def set_direction
		# right to left language support
		@locale_direction = Yetting.rtl_locales.include?(I18n.locale) ? 'rtl' : 'ltr'
	end

	# FIXME: these are simple rot13
	def obfuscate(s)
		s.tr("A-Ma-mN-Zn-z","N-Zn-zA-Ma-m")
	end

	def unobfuscate(s)
		s.tr("N-Zn-zA-Ma-m", "A-Ma-mN-Zn-z")
	end

	def current_user_session
		return @current_user_session if defined?(@current_user_session)
		@current_user_session = UserSession.find
	end

	def current_user
		return @current_user if @current_user.present?
		@current_user = current_user_session && current_user_session.record
	end

	def login_required
		unless current_user
			store_location
			flash[:info] = I18n.t('must_be_logged_in')
			redirect_to new_user_session_path
			return false
		end
	end

	def login_required_unless_guest_dashboard
		guest_dashboard = Setting.get("guest-dashboard")
		return true if guest_dashboard && guest_dashboard == "1"
		login_required
	end

	def admin_required
		return false if login_required == false
		unless current_user.admin?
			store_location
			flash[:info] = t('must_be_admin')
			redirect_to new_user_session_url
			return false
		end
	end

	def store_location
		session[:return_to] = request.fullpath
	end

	def set_title(title)
		@page_title = title
	end

	def no_subtabs
		@no_subtabs = true
	end

	# set up all plugins to be used
	def prepare_plugins
		# this gets the tabs available
		@tabs = Tab.all
	end

	def development?
		Rails.env == 'development'
	end

	def test?
		Rails.env == 'test'
	end

	# setting here to enable we want using sample data
	def use_sample_data?
		# for simplicity, turn it on if running in development
		development? || test?
	end

	protected

    def theme_resolver
      params[:theme] ||= "red"
    end
end
