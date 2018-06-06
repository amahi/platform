Users::Engine.routes.draw do
	root :to => 'users#index'

	resources :users do
		member do
			put 'toggle_admin'
			put 'update_password'
			put 'update_name'
			put 'update_pubkey'
			put 'update_pin'
		end
	end
	match 'settings' => 'users#settings' ,via: [:get,:post]
end
