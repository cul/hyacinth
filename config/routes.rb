require 'resque/server'

Hyacinth::Application.routes.draw do
  resources :csv_exports, only: [:index, :create, :show, :destroy]
  resources :terms, constraints: { id: URI.regexp }

  resources :controlled_vocabularies do
    member do
      get 'terms', action: 'terms', as: 'terms' # terms_controlled_vocabulary_path
      get 'term_additional_fields', action: 'term_additional_fields', as: 'term_additional_fields' # term_additional_fields_controlled_vocabulary_path
    end
    collection do
      match 'search', via: [:get, :post]
    end
  end

  resources :digital_object_types

  resources :dynamic_fields
  resources :dynamic_field_groups
  resources :dynamic_field_group_categories

  resources :thumbs, only: [:show]

  resources :pid_generators
  resources :xml_datastreams

  # add actions as needed, remove "only:" restriction if all actions needed
  resources :import_jobs, only: [:index, :new, :create, :show, :destroy] do
    resources :digital_object_imports, only: [:index, :show]
  end

  resources :digital_object_imports, only: [:index, :show]

  resources :digital_objects do
    collection do
      match 'search', via: [:get, :post]
      match 'search_results_to_csv', via: [:get, :post]
      match 'data_for_editor', via: [:get, :post]
      post 'upload_assets'
      get 'upload_directory_listing'
      get 'titles_for_pids'
    end
    member do
      get 'data_for_ordered_child_editor'
      get 'download'
      get 'media_view'
      get 'mods'
      put 'undelete', action: 'undestroy'
      put 'add_parent', action: 'add_parent'
      put 'remove_parents', action: 'remove_parents'
      post 'rotate_image', action: 'rotate_image'
      post 'swap_order_of_first_two_child_assets', action: 'swap_order_of_first_two_child_assets'
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

  # Make sure that the resque user restriction below is AFTER `devise_for :users`

  resque_web_constraint = lambda do |request|
    current_user = request.env['warden'].user
    current_user.present? && current_user.respond_to?(:is_admin?) && current_user.is_admin?
  end
  constraints resque_web_constraint do
    mount Resque::Server.new, at: "/resque"
  end

  resources :publish_targets

  resources :projects do
    member do
      resource :permissions, controller: 'projects/permissions', only: [:edit, :update], as: :project_permissions
      resource :publish_targets, controller: 'projects/publish_targets', only: [:edit, :update], as: :project_publish_targets
      resource :dynamic_fields, controller: 'projects/dynamic_fields', only: [:edit, :update], as: :enabled_dynamic_fields
      resources :fieldsets, as: 'project_fieldsets'
      # TODO: Move select_dynamic_fields_for_csv_export to projects/exports/new
      get 'select_dynamic_fields_for_csv_export', action: 'select_dynamic_fields_for_csv_export', as: 'select_dynamic_fields_for_csv_export' # select_dynamic_fields_for_csv_export
      # TODO: Figure out what the intent of select_dynamic_fields_csv_header_for_import is
      get 'select_dynamic_fields_csv_header_for_import', action: 'select_dynamic_fields_csv_header_for_import', as: 'select_dynamic_fields_csv_header_for_import' # select_dynamic_fields_csv_header_for_import
    end

    collection do
      get 'where_current_user_can_create', action: 'where_current_user_can_create'
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
