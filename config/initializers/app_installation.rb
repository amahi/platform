if (AmahiHDA::Application.config.daemon)
	controller = Daemons::Rails::Monitoring.controller("app_installation.rb")
	controller.stop
	AmahiHDA::Application.config.daemon = true
	controller.start # => starts
end
