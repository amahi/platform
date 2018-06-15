Rails.application.routes.draw do

  amahi_plugin_routes

  match 'login' => 'user_sessions#new', :as => :login, via: [:get]
  match 'logout' => 'user_sessions#destroy', :as => :logout, via: [:get]
  match 'start' => 'user_sessions#start', :as => :start, via: [:get]
  match 'user_sessions/initialize_system' => 'user_sessions#initialize_system', :as => :initialize_system, via: [:get,:post]

  get '/tab/debug'=>'debug#index'
  post '/tab/debug'=>'debug#submit'
  get '/tab/debug/system'=>'debug#system'
  get '/tab/debug/logs'=>'debug#logs'

  resources :shares do
    collection do
      get 'disk_pooling'
      get 'settings'
      put 'toggle_disk_pool_partition'
    end

    member do
      put 'toggle_visible'
      put 'toggle_everyone'
      put 'toggle_readonly'
      put 'toggle_access'
      put 'toggle_write'
      put 'toggle_guest_access'
      put 'toggle_guest_writeable'
      put 'update_tags'
      put 'update_path'
      put 'update_workgroup'
      put 'toggle_disk_pool'
      put 'update_extras'
      put 'clear_permissions'
    end
  end

  resources :user_sessions, :hosts, :aliases

  match 'search/hda' => 'search#hda', :as => :search_hda, via: [:get,:post]
  match 'search/images' => 'search#images', :as => :search_images, via: [:get,:post]
  match 'search/audio' => 'search#audio', :as => :search_audio, via: [:get,:post]
  match 'search/video' => 'search#video', :as => :search_video, via: [:get,:post]

  root :to => 'front#index'
  
  match 'aliases/new(.:format)' => 'aliases#new', via: [:get]
  match 'aliases(.:format)' => 'aliases#index', via: [:get]
  match 'aliases/:id(.:format)' => 'aliases#show', via: [:get]
  match 'aliases/:id/edit' => 'aliases#edit', via: [:get]
  match 'aliases(.:format)' => 'aliases#create', via: [:post]
  match 'aliases/:id(.:format)' => 'aliases#update', via: [:put]
  match 'aliases/:id(.:format)' => 'aliases#destroy', via: [:delete]
  match 'aliases/update_address/:id' => 'aliases#update_address', via: [:get]
  match 'aliases/delete/:id' => 'aliases#delete', via: [:get]
  match 'aliases/new_alias_check' => 'aliases#new_alias_check', via: [:get]
  match 'aliases/new_address_check' => 'aliases#new_address_check', via: [:get]

  match 'hosts/new(.:format)' => 'hosts#new', via: [:get]
  match 'hosts(.:format)' => 'hosts#index', via: [:get]
  match 'hosts/:id(.:format)' => 'hosts#show', via: [:get]
  match 'hosts/:id/edit' => 'hosts#edit', via: [:get]
  match 'hosts(.:format)' => 'hosts#create', via: [:post]
  match 'hosts/:id(.:format)' => 'hosts#update', via: [:put]
  match 'hosts/:id(.:format)' => 'hosts#destroy', via: [:delete]
  match 'hosts/update_address(/:id)' => 'hosts#update_address', via: [:get]
  match 'hosts/update_mac(/:id)' => 'hosts#update_mac', via: [:get]
  match 'hosts/delete(/:id)' => 'hosts#delete', via: [:get]
  match 'hosts/new_host_check' => 'hosts#new_host_check', via: [:get]
  match 'hosts/new_address_check' => 'hosts#new_address_check', via: [:get]
  match 'hosts/new_mac_check' => 'hosts#new_mac_check', via: [:get]
  match 'hosts/wake_system(/:id)' => 'hosts#wake_system', via: [:get]
  match 'hosts/wake_mac' => 'hosts#wake_mac', via: [:get]

  match 'server/start(/:id)' => 'server#start', via: [:get]
  match 'server/restart(/:id)' => 'server#restart', via: [:get]
  match 'server/stop(/:id)' => 'server#stop', via: [:get]
  match 'server/refresh(/:id)' => 'server#refresh', via: [:get]
  match 'server/toggle_monitored(/:id)' => 'server#toggle_monitored', via: [:get]
  match 'server/toggle_start_at_boot(/:id)' => 'server#toggle_start_at_boot', via: [:get]
  
  match 'share/update_name(/:id)' => 'share#update_name', via: [:get]
  match 'share/update_extras(/:id)' => 'share#update_extras', via: [:get]
  match 'share/update_path(/:id)' => 'share#update_path', via: [:get]
  match 'share/update_tags(/:id)' => 'share#update_tags', via: [:get]
  match 'share/delete(/:id)' => 'share#delete', via: [:get]
  match 'share/create' => 'share#create', via: [:get]
  match 'share/new_share_name_check' => 'share#new_share_name_check', via: [:get]
  match 'share/new_share_path_check' => 'share#new_share_path_check', via: [:get]
  match 'share/toggle_everyone/:id' => 'share#toggle_everyone', via: [:get]
  match 'share/toggle_guest_access/:id' => 'share#toggle_guest_access', via: [:get]
  match 'share/toggle_guest_writeable/:id' => 'share#toggle_guest_writeable', via: [:get]
  match 'share/toggle_access/:id' => 'share#toggle_access', via: [:get]
  match 'share/toggle_write/:id' => 'share#toggle_write', via: [:get]
  match 'share/toggle_readonly/:id' => 'share#toggle_readonly', via: [:get]
  match 'share/toggle_visible/:id' => 'share#toggle_visible', via: [:get]
  match 'share/toggle_tag/:id' => 'share#toggle_tag', via: [:get]
  match 'share/toggle_setting/:id' => 'share#toggle_setting', via: [:get]
  match 'share/update_workgroup_name/:id' => 'share#update_workgroup_name', via: [:get]
  match 'share/toggle_disk_pool_enabled/:id' => 'share#toggle_disk_pool_enabled', via: [:get]
  match 'share/update_disk_pool_copies/:id' => 'share#update_disk_pool_copies', via: [:get]
  match 'share/toggle_disk_pool_partition' => 'share#toggle_disk_pool_partition', via: [:get]

end
