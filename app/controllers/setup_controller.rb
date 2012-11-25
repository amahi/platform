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

class SetupController < ApplicationController

	before_filter :admin_required

	def index
		tab = params[:tab] || 'user'
		subtab = params[:sub]
		setup_menus(tab)

		# FIXME: HACK
		if tab == 'themes' or tab == 'theme'
			tab = 'setting'
			subtab = 'themes'
		end

		# for backward compatibility to some old themes in the F11 release 11/10/09
		stab = tab.singularize

		begin
			@tabSelection = @tabs.select{ |t| t[:controller] == stab }.first
			@subtabSelection = subtab ? @tabSelection[:menus].select{ |m| m.first == subtab }.first : @tabSelection[:menus].first
			subtab = @subtabSelection.first
		rescue
			@subtabSelection = @tabSelection[:menus].first
			subtab = @subtabSelection.first
			flash.now[:error] = "That menu/tab does not exist (maybe you need to turn on advanced settings?)"
		end

		# FIXME - this needs to be done programmable, and accesible via
		# some API call

		case stab
		when 'storage'
			@page_title = t 'storage'
			@partitions = PartitionUtils.new.info
			@disks = DiskUtils.new.info
		when 'user'
			@page_title = t 'users'
			@users = User.all_users
		when 'share'
			@page_title = t 'shares'
			Share.create_default_shares if Share.count == 0
			@shares = Share.all.sort { |x,y| x.comment.casecmp y.comment }
			@debug = Setting.shares.f('debug')
			@pdc = Setting.shares.f('pdc')
			@workgroup = Setting.shares.f('workgroup')
			@win98 = Setting.shares.f('win98')
			# do not show if there little free space (unless it's already in the pool! maybe it got full)
			# note: the 200mb cuts out the default /boot partition
			@partitions = PartitionUtils.new.info.delete_if { |p| p[:bytes_free] < 200.megabytes and not DiskPoolPartition.find_by_path(p[:path]) }
			@broken_disk_pool_partitions = DiskPoolPartition.all.delete_if { |dpp| ! @partitions.select{|p| p[:path] == dpp.path}.empty? }
		when 'network'
			@domain = Setting.get 'domain'
			@page_title = t 'networking'
			# FIXME-cpg: only compute what is needed for a given tab - more efficient
			@leases = Leases.all
			@hosts = Host.all
			@net = Setting.get('net')
			@self = [@net, Setting.get('self-address')].join '.'
			@aliases = DnsAlias.user_visible
			@fw_rules = Firewall.all
			@max = VALID_DHCP_ADDRESS_RANGE-1 

			# FIXME: DRY the stuff below from the network controller (setup_router)
			require 'router_driver'
			setup_router

		when 'theme'
			@page_title = t 'themes'
			@themes = Theme.available
		when 'app'
			@page_title = t 'apps'
			case subtab
			when 'available'
				begin
					@apps_available = App.available
				rescue
					@apps_available = []
				end
			when 'installed'
				@apps_installed = App.latest_first
			when 'webapps'
				@webapps = Webapp.all
			else
			end
		when 'setting'
			@page_title = t 'settings'
			case subtab
			when 'settings'
				@available_locales = locales_implemented
				@firewall = Setting.find_by_name('firewall')
				@version = versions
				# create it initial if not present. eeewww
				Setting.set_kind("general", "guest-dashboard", false) unless Setting.get('guest-dashboard')
				@guest_dashboard = Setting.find_by_name('guest-dashboard')
			when 'servers'
				@page_title = t 'servers'
				@servers = Server.all
			when 'themes'
				@page_title = t 'themes'
				@themes = Theme.available
			when 'calendars'
    				Dir.chdir("/var/hda/calendar/html") { @calendars = Dir["*.ics"] }
				@has_ical = App.find_by_name 'iCalendar' != nil
			else
			end
		when 'debug'
			@page_title = t 'debug'
		else
			raise NoSuchTab, stab
		end
	end

	def showMsg
		render :partial => 'showMsg'
	end

	def addTab (newtab)
		@tabs += newtab
	end

	#def set_theme
		#s = Setting.find_by_name "theme"
		#s.value = params[:name]
		#s.save!
		#redirect_to :controller => 'setup', :tab => 'theme'
	#end

	def submit_debug_report
		AmahiApi.api_key = Setting.get "api-key"
		report = SystemUtils.run 'tail -200 /var/hda/platform/html/log/production.log'
		er = AmahiApi::ErrorReport.new(:report => report, :comments => params[:comments], :subject => params[:subject])
		begin
			if er.save
				render :partial => "debug/debug_submit_worked", :locals => { :error_id => er.id }
			else
				render :partial => "debug/debug_submit_failed", :locals => { :errors => er.errors }
			end
		rescue
			render :partial => "debug/debug_submit_failed", :locals => { :errors => er.errors }
		end
	end

	def disk_graph
		require 'gruff'
		total = params[:total].to_i
		free = params[:free].to_i
		used = (total - free)
		path = params[:path]
		index = params[:index]

		g = Gruff::Pie.new(400)
		title = total > 0 ? "#{number_helpers.number_to_human_size(total)}" : " :-( "
		if (Setting.find_by_name('advanced').value == '1') or (total == 0)
			g.title = "#{path}   #{title}"
		else
			g.title = "#{t 'partition'} #{index}   #{title}"
		end

		begin
			g.theme = @theme_gruff
		rescue
			g.theme_37signals
		end

		g.data("Free: #{number_helpers.number_to_human_size(free)}", free);
		g.data("Used: #{number_helpers.number_to_human_size(used)}", used);

		send_data(g.to_blob, :disposition => 'inline', :type => 'image/png', :filename => "part#{path}.png")
	end

	# this is for testing and debugging translations
	def reload_translations
		I18n.reload!
		redirect_to '/translate'
	end

protected


	def setup_menus(tab)
		# initialize the firewall setting
		fws = Setting.find_by_name('firewall')
		as = Setting.find_by_name('advanced')
		advanced = as && as.value == '1'
		firewall = advanced && fws && fws.value == '1'
		@page_title = t('setup')
		# menu filename of the partial and string to print
		def subm(s)
			return ['index', ''] if s.blank?
			[s, t(s)]
		end
		# list of tabs:
		#   - order selects the order in which they are presented (done like this to allow for expansion)
		#   - controller which owns the tab
		#   - title of the tab
		#   - menu is a list of submenus, such that for each submenu:
		# 	submenu.first is the name of the partial controlling it, submenu.last is the string that gets printed (via subm above)
		@tabs = [
			{ :order => 50,
				:controller => 'user',
				:title => t('users'),
				:menus => [subm('')]
			},
			{ :order => 60,
				:controller => 'share',
				:title => t('shares'),
				:menus => [subm('shares')] + (advanced ? [subm('disk_pooling'), subm('settings')] : [])
			},
			{ :order => 70,
				:controller => 'app',
				:title => t('apps'),
				:menus => [subm('available'), subm('installed')] + (advanced ? [subm('webapps')] : [])
			},
			{ :order => 80,
				:controller => 'storage',
				:title => t('storage'),
				:menus => [subm('partitions'), subm('disks')]
			},
			{ :order => 90,
				:controller => 'network',
				:title => t('networking'),
				:menus => [subm('dhcp'), subm('static_ips')] + (advanced ? [subm('aliases')] : []) + (firewall ? [subm('firewall')] : []) + (advanced ? [subm('settings')] : [])
			},
			{ :order => 110,
				:controller => 'setting',
				:title => t('settings'),
				:menus => [subm('settings'), subm('servers'), subm('themes'), subm('calendars')]
			},
		]

		# UI enhancement - only show when invoked explicitly or w/ advanced settings
		if advanced || tab == "debug"
			@tabs << { :order => 140,
				:controller => 'debug',
				:title => t('debug'),
				:menus => [subm('app_logs'), subm('system'), subm('logs')]
			}
		end
	end

	# FIXME: too simple password checking!
	# note - some users may even want less restrictions!
	def passwd_check(pwd, conf)
		(not pwd.nil?) and pwd == conf and pwd.size > 1
	end

	def versions
		platform = ""
		hdactl = ""
		if Platform.fedora?
			open("|rpm -q hda-platform hdactl") do |f|
				while f.gets
					line = $_
					if (line =~ /hda-platform-(.*).noarch/)
						platform = $1
					end
					if (line =~ /hdactl-([0-9\.\-]+)\.\w+/)
						hdactl = $1
					end
				end
			end
		else
			open("|apt-cache show hda-platform | grep Version") do |f|
				f.gets
				line = $_
				if (line =~ /Version: (.*)/)
					platform = $1
				end
			end
			open("|apt-cache show hdactl | grep Version") do |f|
				f.gets
				line = $_
				if (line =~ /Version: (.*)/)
					hdactl = $1
				end
			end

		end
		{ :platform => platform, :hdactl => hdactl }
	end

end
