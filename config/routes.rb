Hyacinth::Application.routes.draw do

  resources :authorized_terms

  resources :controlled_vocabularies do
    member do
      get 'authorized_terms', :action => 'authorized_terms', :as => 'authorized_terms' # authorized_terms_controlled_vocabulary_path
    end
    collection do
      match 'search', via: [:get, :post]
    end
  end

  resources :fieldsets

  resources :digital_object_types

  resources :dynamic_fields
  resources :dynamic_field_groups
  resources :dynamic_field_group_categories

  resources :thumbs, only: [:show]

  resources :pid_generators
  resources :xml_datastreams

  resources :digital_objects do
    collection do
      match 'search', via: [:get, :post]
      match 'data_for_editor', via: [:get, :post]
      post 'upload_assets'
    end
    member do
      get 'data_for_ordered_child_editor'
      get 'download'
      get 'media_view'
      get 'mods'
      put 'undelete', action: 'undestroy'
      put 'add_parent', action: 'add_parent'
      post 'rotate_image', action: 'rotate_image'
      post 'swap_order_of_first_two_child_assets', actions: 'swap_order_of_first_two_child_assets'
    end
  end

  get '/login_check', to: 'pages#login_check'
  get '/get_csrf_token', to: 'pages#get_csrf_token'
  get '/home', to: 'pages#home', as: :home
  get '/system_information', to: 'pages#system_information', as: :system_information

  get '/users/do_wind_login', to: 'users#do_wind_login', as: :user_do_wind_login
  get '/users/do_cas_login', to: 'users#do_cas_login', as: :user_do_cas_login
  devise_for :users
  resources :users

  resources :publish_targets

  resources :projects do
    member do
      get 'edit_project_permissions', :action => 'edit_project_permissions', :as => 'edit_project_permissions' # edit_project_permissions_project_path
      patch 'update_project_permissions'
      get 'edit_publish_targets', :action => 'edit_publish_targets', :as => 'edit_publish_targets' # edit_publish_targets_project_path
      patch 'update_publish_targets'
      get 'edit_enabled_dynamic_fields/:digital_object_type_id', :action => 'edit_enabled_dynamic_fields', :as => 'edit_enabled_dynamic_fields' # edit_enabled_dynamic_fields_project_path
      patch 'update_enabled_dynamic_fields/:digital_object_type_id', :action => 'update_enabled_dynamic_fields'
      get 'fieldsets', :action => 'fieldsets', :as => 'fieldsets' # fieldsets_project_path
    end

    collection do
      get 'where_current_user_can_create', :action => 'where_current_user_can_create'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
