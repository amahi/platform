class PluginGenerator < Rails::Generators::NamedBase
	source_root File.expand_path('../templates', __FILE__)

	# utility method to be called by file name substitution in calls to directory
	def classname_lower
		"#{plural_name.underscore}"
	end

	def create_config_file
		root = "plugins/#{plural_name}"
		# FIXME bug in thor?
		# destination_root="#{Rails.root}/plugins/#{plural_name}"

		copy_file 'Gemfile', "#{root}/Gemfile"
		copy_file 'LICENSE', "#{root}/LICENSE"
		copy_file 'README.rdoc', "#{root}/README.rdoc"
		copy_file 'Rakefile', "#{root}/Rakefile"
		['app', 'config', 'db', 'lib', 'script'].each do |d|
			directory d, "#{root}/#{d}"
		end

		inside(root) do
			create_file "config/amahi-plugin.yml", <<-FILE
# human readable name (no localization supported yet)
name: #{class_name}
# class to be mounted
class: #{plural_name.camelize}
# root url where this plugin will be mounted
url: /tab/#{plural_name}
			FILE
		end

		inside(root) do
			create_file "#{plural_name}.gemspec", <<-FILE
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "#{plural_name}/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "#{plural_name}"
  s.version     = #{class_name}::VERSION
  s.authors     = ["Your Name"]
  s.email       = ["your@email.example.com"]
  s.homepage    = "http://www.amahi.org/apps/yourapp"
  s.license     = "AGPLv3"
  s.summary     = %{Your plugin does this and that.}
  s.description = %{This is an Amahi 7 platform plugin that does fantastic wizbang things with amazing technology.}

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
			FILE
		end

		inside(root) do
			create_file "lib/#{plural_name.downcase}.rb", <<-FILE
require "#{plural_name}/version"
require "#{plural_name}/engine"

module #{class_name}
	class Lib
		# the code for your plugin library here
		# or inside lib/#{plural_name}/whatever.rb and required here
	end
end
			FILE
		end

		inside(root) do
			create_file "lib/#{plural_name}/version.rb", <<-FILE
module #{class_name}
	VERSION = "0.0.1"
end
			FILE
		end

		inside(root) do
			create_file "lib/#{plural_name}/engine.rb", <<-FILE
module #{plural_name.camelize}
	class Engine < ::Rails::Engine
		# NOTE: do not isolate the namespace unless you really really
		# want to adjust all your controllers views, etc., making Amahi's
		# platform hard to reach from here
		# isolate_namespace #{class_name}
	end
end
			FILE
		end

		inside(root) do
			create_file "lib/tasks/#{plural_name}.rake", <<-FILE
# desc "Explaining what the task does"
# task :#{plural_name} do
#   # Task goes here
# end
			FILE
		end

		# FIXME -- if the plugin is not a tab, this below needs to be parameterized
		inside(root) do
			create_file "config/routes.rb", <<-FILE
#{plural_name.camelize}::Engine.routes.draw do
	# root of the plugin
        root :to => '#{plural_name}#index'
	# examples of controllers built in this generator. delete at will
	match 'settings' => '#{plural_name}#settings',:via=> :all
	match 'advanced' => '#{plural_name}#advanced',:via => :all
end
			FILE
		end

		inside(root) do
			create_file "script/rails", <<-FILE
#!/usr/bin/env ruby

ENGINE_ROOT = File.expand_path('../..', __FILE__)
ENGINE_PATH = File.expand_path('../../lib/#{plural_name}/engine', __FILE__)
require 'rails/all'
require 'rails/engine/commands'
			FILE
			chmod "script/rails", 0755
		end

		inside(root) do
			initializer("plugin_init.rb") do
				data = ['# plugin initialization']
				data << "t = Tab.new(\"#{plural_name}\", \"#{plural_name}\", \"/tab/#{plural_name}\")"
				data << '# add any subtabs with what you need. params are controller and the label, for example'
				data << 't.add("index", "details")'
				data << 't.add("settings", "settings")'
				data << 't.add("advanced", "advanced")'
				data.join("\n")
			end
		end

		inside(root) do
			create_file "app/controllers/#{plural_name.downcase}_controller.rb", <<-FILE
class #{plural_name.camelize}Controller < ApplicationController
	before_action :admin_required

	def index
		# do your main thing here
	end

#	def settings
#		# do the settings page here
#	end

#	def advanced
#		# do the advanced settings page here
#	end
end
			FILE
		end
	end
end
