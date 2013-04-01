Shares::Engine.routes.draw do
	# root of the plugin
        root :to => 'shares#index'
	# examples of controllers built in this generator. delete at will
	match 'settings' => 'shares#settings'
	match 'advanced' => 'shares#advanced'
end
