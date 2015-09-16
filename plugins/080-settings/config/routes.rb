Settings::Engine.routes.draw do
	# root of the plugin
        root :to => 'settings#index'
	match 'change_language' => 'settings#change_language', via: [:get,:post]
	match 'toggle_setting' => 'settings#toggle_setting', via: [:get,:post]
	match 'reboot' => 'settings#reboot', via: [:get,:post]
	match 'poweroff' => 'settings#poweroff', via: [:get,:post]
	match 'servers' => 'settings#servers', via: [:get,:post]
	match 'servers/:id/refresh' => 'settings#refresh', as: 'refresh', via: [:get,:post]
	match 'servers/:id/start' => 'settings#start', as: 'start', via: [:get,:post]
	match 'servers/:id/stop' => 'settings#stop', as: 'stop', via: [:get,:post]
	match 'servers/:id/restart' => 'settings#restart', as: 'restart', via: [:get,:post]
	match 'servers/:id/toggle_monitored' => 'settings#toggle_monitored', as: 'toggle_monitored', via: [:get,:post, :put]
	match 'servers/:id/toggle_start_at_boot' => 'settings#toggle_start_at_boot', as: 'toggle_start_at_boot', via: [:get,:post,:put]
	match 'refresh' => 'settings#refresh', via: [:get,:post]
	match 'themes' => 'settings#themes', via: [:get,:post]
	match 'activate_theme' => 'settings#activate_theme', via: [:get,:post]

	put 'revoke_app' => 'settings#revoke_app', as: 'revoke_app'
end
