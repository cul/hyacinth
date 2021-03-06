# frozen_string_literal: true

require 'resque/server'

Rails.application.routes.draw do
  # Constraint for restricting certain routes to only admins, or to the development environment
  dev_or_admin_constraints = lambda do |request|
    return true if Rails.env.development?
    current_user = request.env['warden'].user
    current_user&.is_admin?
  end

  # For now, we can only use GraphiQL in the development environmnent (due to a js compilation issue in prod).
  if Rails.env.development?
    constraints dev_or_admin_constraints do
      mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    end
  end

  constraints dev_or_admin_constraints do
    mount Resque::Server.new, at: "/resque"
  end

  post "/graphql", to: "graphql#execute"

  get '/users/do_cas_login', to: 'users#do_cas_login', as: :user_do_cas_login
  devise_for :users

  root to: redirect('ui/v1')
  get 'ui', to: redirect('ui/v1')
  get 'ui/v1', to: 'ui#v1'
  # wildcard *path route so that everything under ui/v1 gets routed to the single-page app
  get 'ui/v1/*path', to: 'ui#v1'

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :digital_objects, except: :index do
        collection do
          # allow GET or POST for search action requests so we don't run into param length limits
          get 'search'
          post 'search'
          post ':id/publish' => 'digital_objects#publish', as: :publish
          post ':id/preserve' => 'digital_objects#preserve', as: :preserve
        end
        member do
          get 'resources/:resource_name/download' => 'digital_objects/resources#download', as: :download_resource
        end
      end

      resources :projects, param: :string_key, only: [:show] do
        resources :publish_targets, param: :string_key, except: [:new, :edit], module: 'projects'
        resources :field_sets,                          except: [:new, :edit], module: 'projects'
        resources :enabled_dynamic_fields,
                  only: [:show, :update], module: 'projects',
                  param: :digital_object_type, constraints: { digital_object_type: /(#{Hyacinth::Config.digital_object_types.keys.join('|')})/ }
      end

      resources :dynamic_field_categories, only: [:index]

      post 'uploads' => 'uploads#create', as: :upload

      namespace :downloads do
        get '/digital_object/:id/:resource_name', action: :digital_object, as: :digital_object
        get '/batch_export/:id', action: :batch_export, as: :batch_export
        get '/batch_import/:id(/:option)', action: :batch_import, as: :batch_import, constraints: { option: /(without_successful_imports)/ }
      end
    end
  end
end
