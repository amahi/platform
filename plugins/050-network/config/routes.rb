Network::Engine.routes.draw do
	# root of the plugin
  root :to => 'network#index'
	get 'leases' => 'network#index'
	get 'hosts' => 'network#hosts'
  post 'hosts' => 'network#create_host'
  delete 'host/:id' => 'network#destroy_host', as: 'destroy_host'
	get 'aliases' => 'network#aliases'
	get 'settings' => 'network#settings'
end
