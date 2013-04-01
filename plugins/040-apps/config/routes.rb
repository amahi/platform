Apps::Engine.routes.draw do
	# root of the plugin
        root :to => 'apps#index'
	# examples of controllers built in this generator. delete at will
	match 'installed' => 'apps#installed'
	match 'webapps' => 'apps#advanced'

  resources :apps do
    collection do
      get 'installed'
    end

    member do
      post 'install_via_daemon'
      get 'install_progress'

      post 'uninstall_via_daemon'
      get 'uninstall_progress'

      put 'toggle_in_dashboard'
    end
  end
end
