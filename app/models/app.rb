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


require 'tempfile'
require 'digest/md5'



class App < ActiveRecord::Base

	APP_PATH = Rails.env == "development" ? "/tmp/app/%s" : "/var/hda/apps/%s"
	WEBAPP_PATH = Rails.env == "development" ? "/tmp/web-apps/%s" : "/var/hda/web-apps/%s"
	INSTALLER_LOG = "/var/log/amahi-app-installer.log"

	belongs_to :webapp, :dependent => :destroy
	belongs_to :theme, :dependent => :destroy
	belongs_to :db, :dependent => :destroy
	belongs_to :server, :dependent => :destroy
	belongs_to :share, :dependent => :destroy

	has_many :app_dependencies, :dependent => :destroy
	has_many :children, :class_name => "AppDependency", :foreign_key => 'dependency_id'
	has_many :dependencies, :through => :app_dependencies

	scope :installed, where(:installed => true)
	scope :in_dashboard, where(:show_in_dashboard => true).installed
	scope :latest_first, :order => 'updated_at desc'

	before_destroy :before_destroy_hook

  validates :name, :presence => true
  validates :identifier, :presence => true, :uniqueness => true



	def initialize(identifier, app=nil)
		super()
		if app.nil?
			AmahiApi::api_key = Setting.value_by_name("api-key")
			app = AmahiApi::App.find(identifier)
		end
		# online_app_to_local_app(app)
		self.name = app.name
		self.screenshot_url = app.screenshot_url
		self.identifier = app.id
		self.description = app.description
		self.version = app.version
		self.app_url = app.app_url
		self.logo_url = app.logo_url
		self.status = app.status
		self.installed = false
	end

	def install_start
		App.transaction do
			self.installed = false
			self.install_status = 0
			self.save!
		end
		p = Process.fork do
			App.transaction { install_bg }
			return
		end
		Process.detach(p)
	end

	def uninstall_start
		p = Process.fork do
			App.transaction { uninstall_bg }
			return
		end
		Process.detach(p)
	end

	def self.install_via_daemon(identifier)
		# run the kickoff script
		cmd = File.join(Rails.root, "script/install-app --environment=#{Rails.env} #{identifier} >> #{INSTALLER_LOG} 2>&1 &")
		c = Command.new cmd
		c.execute
	end


	def uninstall_via_daemon
		# run the kickoff script
		cmd = File.join(Rails.root, "script/install-app -u --environment=#{Rails.env} #{self.identifier} >>  #{INSTALLER_LOG} 2>&1 &")
		c = Command.new cmd
		c.execute
	end

	def self.available
		AmahiApi::api_key = Setting.value_by_name("api-key")
		begin
			av = AmahiApi::App.find(:all).map do |online_app|
				a = App.find_by_identifier online_app.id
				if a
					nil
				else
					App.new(online_app.id, online_app)
				end
			end
			av.compact
		rescue
			[]
		end
	end

	def install_message
		# NOTE: make sure these messages match the stages below
		App.installation_message self.install_status
	end

	def self.installation_message(percent)
		case percent
			when   0 then "Preparing to install ..."
			when  10 then "Retrieving application information ..."
			when  20 then "Installing app dependencies ..."
			when  30 then "Installing package dependencies ..."
			when  40 then "Downloading application and unpacking it ..."
			when  60 then "Installing the application in your HDA ..."
			when  70 then "Creating associated server in your HDA ..."
			when  80 then "Saving application settings ..."
			when 100 then "Application installed."
			else "Application message unknown at #{percent}% install."
		end
	end

	def uninstall_message
		# NOTE: make sure these messages match the stages below
		case self.install_status
			when 100 then "Preparing to uninstall ..."
			when  80 then "Retrieving application information ..."
			when  60 then "Running uninstall scripts ..."
			when  40 then "Removing application files ..."
			when  20 then "Uninstalling application ..."
			when   0 then "Application uninstalled."
			else "Application message unknown at #{self.install_status}% uninstall."
		end
	end

	def install_status
		App.installation_status(self.identifier)
	end

	def self.installation_status(identifier)
		status = Setting.find_by_kind_and_name(identifier, 'install_status')
		return 0 unless status
		status.reload
		status.value.to_i
	end

	def install_status=(value)
		status = Setting.find_by_kind_and_name(self.identifier, 'install_status')
		if value.nil?
			status.destroy if status
			return nil
		end
		if status 
			status.update_attribute(:value, value.to_s)
			status.reload
			return value
		end
		# create it dynamically if it does not exist
		status = Setting.create(:kind => self.identifier, :name => 'install_status', :value => value.to_s)
		status.reload
		value
	end

	def has_dependents?
		children != []
	end

	def install_bg
		initial_path = Dir.pwd
		begin
			status = Setting.create(:kind => self.identifier, :name => 'install_status', :value => "0")
			# see the install_message method for the meaning of the messages
			self.install_status = 0
			AmahiApi::api_key = Setting.value_by_name("api-key")
			self.install_status = 10
			installer = AmahiApi::AppInstaller.find identifier
			self.install_status = 20
			self.install_app_deps installer if installer.app_dependencies
			self.install_status = 30
			self.install_pkg_deps installer if installer.pkg_dependencies
			self.install_pkgs installer if installer.pkg
			app_path = APP_PATH % identifier
			mkdir app_path
			webapp_path = nil
			self.install_status = 40
			unless installer.url_name.nil?
				(name, webapp_path) = self.install_webapp installer
				self.show_in_dashboard = true
			else
				self.show_in_dashboard = false
			end
			self.create_db(:name => installer.database) if installer.database && !installer.database.blank?
			# if it has a share, create it and install it
			if installer.share
				sh = Share.find_by_name installer.share
				if sh
					# FIXME: autohook to it. this is for legacy shares. not needed in new installs
					self.share = sh
				else
					c = installer.share.capitalize
					p = Share.full_path(installer.share)
					# FIXME - use a relative path and not harcode the share path here?
					self.create_share(:name => c, :path => p, :rdonly => false, :visible => true, :tags => "")
					cmd = Command.new("chmod 777 #{p}")
					cmd.execute
				end
			end
			self.install_status = 60
			# if it has a server, install it and associate it
			if installer.server
				servername = installer.server
				pidfile = nil
				if servername =~ /(\w+):(.+)/
					servername = $1
					pidfile = $2 unless $2.empty?
				end
				self.create_server(:name => servername, :comment => "#{self.name} Server", :pidfile => pidfile)
			end
			self.install_status = 70
			self.create_webapp(:name => name, :path => webapp_path, :deletable => false, :custom_options => installer.webapp_custom_options, :kind => installer.kind)
			self.theme = self.install_theme(installer) if installer.kind == 'theme'
			# run the script
			initial_user = installer.initial_user
			initial_password = installer.initial_password
			if installer.install_script
				# if there is an installer script, run it
				Dir.chdir(webapp_path ? webapp_path : app_path) do
					SystemUtils.run_script(installer.install_script, name, hda_environment(initial_user, initial_password))
				end
			end
			self.install_status = 80
			self.forum_url = installer.forum_url
			self.initial_user = installer.initial_user
			self.initial_password = installer.initial_password
			self.special_instructions = installer.special_instructions
			# mark it as installed
			self.installed = true
			self.save!
			self.reload
			self.install_status = 100
			Dir.chdir(initial_path)
		rescue Exception => e
			self.install_status = nil
			Dir.chdir(initial_path)
			raise e
		end
	end

	def uninstall_bg
		app_path = APP_PATH % identifier
		begin
			self.install_status = 100
			AmahiApi::api_key = Setting.value_by_name("api-key")
			self.install_status = 80
			uninstaller = AmahiApi::AppUninstaller.find(identifier)
			if uninstaller
				# execute the uninstall script
				self.install_status = 60
				if uninstaller.uninstall_script
					if self.webapp && self.webapp.path
						Dir.chdir(self.webapp.path) do
							SystemUtils.run_script(uninstaller.uninstall_script, name, hda_environment)
						end
					else
						Dir.chdir(app_path) do
							SystemUtils.run_script(uninstaller.uninstall_script, name, hda_environment)
						end
					end
				end
				self.install_status = 20
				self.uninstall_pkgs uninstaller if uninstaller.pkg
			# else
				# FIXME - retry? what if an app is not
				# live at this time??
			end
			# FIXME - set to nil to destroy??
			self.install_status = 0
			self.destroy
			self.install_status = nil
			FileUtils.rm_rf app_path
		rescue Exception => e
			self.install_status = 100
			FileUtils.rm_rf app_path
			raise e
		end
	end

	def theme?
		theme_id != nil
	end

	def full_url
		webapp ? webapp.full_url : "http://#{app_url}.#{Setting.value_by_name('domain')}"
  end

  def testing?
    status == 'testing'
  end

  def live?
    status == 'live'
  end

  def remote_url
    webapp ? "http://#{webapp.name}" : ''
  end



protected

	# extra environment for install scripts
	# *please* update the docs of variables supported at
	# http://wiki.amahi.org/index.php/Script_variables
	def hda_environment(user = nil, password = nil)
		env = {}
		net = Setting.value_by_name('net')
		addr = Setting.value_by_name('self-address')
		dom = Setting.value_by_name('domain')
		env["HDA_IP"] = [net, addr].join '.'
		env["HDA_DOMAIN"] = dom
		env["HDA_APP_DIR"] = Dir.pwd
		env["HDA_APP_NAME"] = self.name
		user && env["HDA_APP_USERNAME"] = user
		password && env["HDA_APP_PASSWORD"] = password
		env["HDA_1ST_ADMIN"] = (User.admins.first.login || "no-admin" ) rescue "error"
		env
	end

	def before_destroy_hook
		# uninstall
	end

	def mkdir(path)
		FileUtils.mkdir_p(path)
	end

	def online_app_to_local_app(online_app)
		name = online_app.name
		screenshot_url = online_app.screenshot_url
		identifier = online_app.id
		description = online_app.description
		version = online_app.version
		app_url = online_app.app_url
		logo_url = online_app.logo_url
		installed = false
	end

	def install_pkgs(installer)
		pkgs = installer.pkg
		return if pkgs.nil? or pkgs.blank?
		pkgs.strip!
		Platform.install(pkgs, installer.source_sha1)
	end

	def install_app_deps(installer)
		deps = installer.app_dependencies
		return [] if deps.nil? or deps.blank?
		deps.strip!
		deps.split(/[, ]+/).map do |identifier|
			a = App.find_by_identifier identifier
			unless a
				a = App.new identifier
				a.install_bg
			end
			# add the dependency if it does not exist
			self.dependencies << a
		end
	end

	def install_pkg_deps(installer)
		deps = installer.pkg_dependencies
		return if deps.nil? or deps.blank?
		deps.strip!
		unless deps.blank?
			Platform.install(deps)
		end
	end

	def uninstall_pkgs(uninstaller)
		deps = uninstaller.pkg
		return if deps.nil? or deps.blank?
		deps.strip!
		unless deps.blank?
			Platform.uninstall(deps)
		end
	end

	def install_theme(installer)

		return if (installer.source_url.nil? or installer.source_url.blank?)

		fname = Downloader.download_and_check_sha1(installer.source_url, installer.source_sha1)

		dir = nil
		Dir.chdir(File.join(Rails.root, THEME_ROOT)) do
			mkdir '.unpack'
			Dir.chdir(".unpack") do
				unpack(installer.source_url, fname)
				# if only one file, move it to html!
				files = Dir.glob('*')
				if files.size == 1
					dir = files.first
					begin; Dir.rmdir("../#{dir}"); rescue; end
					File.rename(files.first, "../#{dir}")
				else
					# FIXME what to do if more file are unpacked
					raise "WARNING: this application unpacks into more than one file. This is a warning sign that it may not install properly!"
				end
			end
			FileUtils.rm_rf ".unpack"
		end
		Theme.dir2theme(dir)
	end

	def install_webapp(installer)

		name = webapp_name(installer.url_name)
		path = WEBAPP_PATH % name

		# clean it first
		FileUtils.rm_rf path

		mkdir File.join(path, 'html')
		mkdir File.join(path, 'logs')

		return [name, path] if (installer.source_url.nil? or installer.source_url.blank?)

		fname = Downloader.download_and_check_sha1(installer.source_url, installer.source_sha1)

		one_dir = true
		Dir.chdir(path) do
			mkdir 'unpack'
			mkdir 'logs'
			Dir.chdir("unpack") do
				unpack(installer.source_url, fname)
				# if only one file, move it to html!
				files = Dir.glob('*')
				if files.size == 1
					Dir.rmdir("../html")
					File.rename(files.first, "../html")
				else
					# FIXME what to do if more file are unpacked
					puts "WARNING: this application unpacks into more than one file/dir. PLEASE contact the authors and well them to unpack into one dir only as most other apps so!"
					puts "NOTE: check the unpack/ directory for all the files"
					one_dir = false
				end
			end
			FileUtils.rm_rf "unpack" if one_dir
		end
		[name, path]
	end

	def unpack(url, fname)
		if (url =~ /\.zip$/)
			f = IO.popen("unzip #{fname}", "w+")
			f.close
		elsif (url =~ /\.(tar.gz|tgz)$/)
			system("tar -xzf #{fname}")
		elsif (url =~ /\.(tar.bz2)$/)
			system("tar -xjf #{fname}")
		else
			raise "File #{url} is not supported for unpacking please report it to the Amahi community!"
		end
	end

	def webapp_name(name)
		i = 0
		add = ""
		begin
			wa = Webapp.find_by_name(name + add)
			return (name+add) if wa.nil?
			raise "cannot find a suitable webapp name. giving up at #{name+add}." if i > 29
			i += 1
			add = i.to_s
		end while i < 100
	end

end
