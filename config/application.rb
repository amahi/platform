require_relative 'boot'

require 'rails/all'
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AmahiHDA
  class Application < Rails::Application

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # initialize tabs app variable
    config.tabs = []

    # in case we need to debug assets
    # config.assets.debug = true

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
