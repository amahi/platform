Shares::Engine.routes.draw do
	# root of the plugin
        root :to => 'shares#index'
	# examples of controllers built in this generator. delete at will
	match 'settings' => 'shares#settings', via: [:get,:post]
	match 'advanced' => 'shares#advanced', via: [:get,:post]
end
