Network::Engine.routes.draw do
	# root of the plugin
  root :to => 'network#index'
	get 'leases' => 'network#index'

	get 'hosts' => 'network#hosts'
  post 'hosts' => 'network#create_host'
  delete 'host/:id' => 'network#destroy_host', as: 'destroy_host'

	get 'dns_aliases' => 'network#dns_aliases'
  post 'dns_aliases' => 'network#create_dns_alias'
  delete 'dns_alias/:id' => 'network#destroy_dns_alias', as: 'destroy_dns_alias'

	get 'settings' => 'network#settings'
	put 'update_lease_time' => 'network#update_lease_time'
end
