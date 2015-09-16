Apps::Engine.routes.draw do
	# root of the plugin
	root :to => 'apps#index'
	# examples of controllers built in this generator. delete at will
	match 'installed' => 'apps#installed', via: [:get,:post]

	post 'install/:id' => 'apps#install', as: 'install'
	match 'install_progress/:id' => 'apps#install_progress', as: 'install_progress', via: [:get,:post]

	post 'uninstall/:id' => 'apps#uninstall', as: 'uninstall'
	match 'uninstall_progress/:id' => 'apps#uninstall_progress', as: 'uninstall_progress', via: [:get,:post]

	put 'toggle_in_dashboard/:id' => 'apps#toggle_in_dashboard', as: 'toggle_in_dashboard'
end
