Rails.application.routes.draw do
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
          # allow GET or POST for search action requests
          # so we don't run into param length limits
          get 'search'
          post 'search'
        end
      end

      resources :users, param: :uid, except: [:new, :edit, :delete] do
        # collection do
        #   get 'current'
        # end
      end

      resources :groups, param: :string_key, except: [:new, :edit]

      resources :vocabularies, param: :string_key, except: [:new, :edit] do
        resources :custom_fields, param: :field_key, except: [:new, :edit, :show, :index], module: 'vocabularies'
        resources :terms, param: :uri, except: [:new, :edit], constraints: { uri: /.*/ }, module: 'vocabularies'
      end

      resources :projects, param: :string_key, except: [:new, :edit] do
        resources :publish_targets, param: :string_key, except: [:new, :edit], module: 'projects'
        resources :field_sets,                          except: [:new, :edit], module: 'projects'
        resources :enabled_dynamic_fields,
                  only: [:show, :update], module: 'projects',
                  param: :digital_object_type, constraints: { digital_object_type: /(#{Hyacinth.config.digital_object_types.keys.join('|')})/ }
      end

      resources :dynamic_field_categories, except: [:new, :edit]
      resources :dynamic_field_groups,     except: [:new, :edit, :index]
      resources :dynamic_fields,           except: [:new, :edit, :index]
    end
  end
end
