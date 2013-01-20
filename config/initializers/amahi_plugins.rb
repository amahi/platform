module AmahiHDA
	module Routes
		# method for adding the routes for plugins
		def amahi_plugin_routes
			AmahiHDA::Application.config.amahi_plugins.each do |plugin|
				klass = Object.const_get(plugin[:class])::Engine
				mount klass, :at => plugin[:url]
			end
		end
	end
end

# make the route plugin method available in the router
module ActionDispatch::Routing
	class Mapper
		include AmahiHDA::Routes
	end
end
