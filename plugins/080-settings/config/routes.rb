Settings::Engine.routes.draw do
	# root of the plugin
        root :to => 'settings#index'
	match 'change_language' => 'settings#change_language'
	match 'toggle_setting' => 'settings#toggle_setting'
	match 'reboot' => 'settings#reboot'
	match 'poweroff' => 'settings#poweroff'
	match 'servers' => 'settings#servers'
	match 'refresh' => 'settings#refresh'
	match 'themes' => 'settings#themes'
	match 'activate_theme' => 'settings#activate_theme'
end
