require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AmahiHDA
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.eager_load_paths << Rails.root.join("lib")

    # Don't generate system test files.
    config.generators.system_tests = nil

    # initialize tabs app variable
    config.tabs = []
  end
end

############################################
# load all Amahi platform plugins installed
############################################
module AmahiHDA
  class Application < Rails::Application
  	PLUGIN_LOCATION = File.join(Rails.root, 'plugins')
  	amahi_plugins = []
  	Dir.glob(File.join(PLUGIN_LOCATION, '*')).sort.each do |dir|
  		file = "#{dir}/config/amahi-plugin.yml"
  		if File.file?(file) and File.readable?(file)
  			plugin = YAML.load(File.read(file)).symbolize_keys
  			plugin[:dir] = File.basename(dir)
  			amahi_plugins << plugin
  			$LOAD_PATH << "#{dir}/lib"
  			Kernel.require plugin[:class].underscore
  		end
  	end
  	# stick them in an app-wide variable for when it's needed by the app
  	config.amahi_plugins = amahi_plugins
  end
end
