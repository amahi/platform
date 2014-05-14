AmahiHDA::Application.routes.draw do

  themes_for_rails
  amahi_plugin_routes

  match 'login' => 'user_sessions#new', :as => :login, via: [:get]
  match 'logout' => 'user_sessions#destroy', :as => :logout, via: [:get]
  match 'start' => 'user_sessions#start', :as => :start, via: [:get]
  match 'user_sessions/initialize_system' => 'user_sessions#initialize_system', :as => :initialize_system, via: [:get,:post]

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

  match 'search/:action' => 'search', :as => :search, via: [:get]

  root :to => 'front#index'

  match ':controller(/:action(/:id))(.:format)', via: [:get]

end
