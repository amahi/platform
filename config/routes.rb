
AmahiHDA::Application.routes.draw do

  themes_for_rails
  amahi_plugin_routes

  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'user_session/set_first_password/:username' => 'user_sessions#set_first_password', :as => :first_password

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
      put 'toggle_disk_pool'
      put 'update_extras'
      put 'clear_permissions'
    end
  end

  resources :user_sessions, :hosts, :aliases

  match 'search/:action' => 'search', :as => :search
  match 'theme/*filename' => 'theme#file'

  root :to => 'front#index'

  match ':controller(/:action(/:id))(.:format)'

end
