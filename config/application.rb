require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AmahiHDA
  class Application < Rails::Application

    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :en
    # config.i18n.enforce_available_locales = true

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
