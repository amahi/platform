Disks::Engine.routes.draw do
	# root of the plugin
        root :to => 'disks#index'
	# examples of controllers built in this generator. delete at will
	match 'mounts' => 'disks#mounts', via: [:get,:post]
end
