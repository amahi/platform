Settings::Engine.routes.draw do
	# root of the plugin
        root :to => 'settings#index'
	match 'change_language' => 'settings#change_language'
	match 'toggle_setting' => 'settings#toggle_setting'
	match 'reboot' => 'settings#reboot'
	match 'poweroff' => 'settings#poweroff'
	match 'servers' => 'settings#servers'
	match 'servers/:id/refresh' => 'settings#refresh', as: 'refresh'
	match 'servers/:id/start' => 'settings#start', as: 'start'
	match 'servers/:id/stop' => 'settings#stop', as: 'stop'
	match 'servers/:id/restart' => 'settings#restart', as: 'restart'
	match 'servers/:id/toggle_monitored' => 'settings#toggle_monitored', as: 'toggle_monitored'
	match 'servers/:id/toggle_start_at_boot' => 'settings#toggle_start_at_boot', as: 'toggle_start_at_boot'
	match 'refresh' => 'settings#refresh'
	match 'themes' => 'settings#themes'
	match 'activate_theme' => 'settings#activate_theme'
end
