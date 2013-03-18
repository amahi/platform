class PluginGenerator < Rails::Generators::NamedBase
	source_root File.expand_path('../templates', __FILE__)

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
class: #{class_name}
# kind of plugin (so far we only support 'tab' plugins)
kind: tab
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
			create_file "lib/#{plural_name}.rb", <<-FILE
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
module #{class_name}
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
#{class_name}::Engine.routes.draw do
        root :to => 'tab#index'
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
	end
end
