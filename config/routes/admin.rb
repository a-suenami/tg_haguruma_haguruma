namespace :admin_area, path: :admin do
  # Auth0 Authentication routes
  get 'login', to: 'auth0#login', as: :login
  get 'logout', to: 'auth0#logout', as: :logout
  get '/auth/auth0/callback', to: 'auth0#callback'
  get '/auth/failure', to: 'auth0#failure'

  root to: 'contents/root#index'
  # root to: 'dashboard#index'
  # get 'dashboard', to: 'dashboard#index'

  # Profile management
  resource :profiles, only: [:edit, :update]

  namespace :contents do
    root to: 'root#index'
    get :mobile, to: 'root#mobile', as: :mobile

    get 'all', to: 'list#all', as: :all
    scope 'types/:content_type_id' do
      root to: 'list#by_content_type', as: :by_content_type

      scope module: :collection, as: :collection do
        resources :entries, only: [:new, :create, :edit, :update], controller: 'entries/edit' do
          resources :text_fields, only: [:update], controller: 'entries/text_fields', param: :api_identifier
          resources :richtext_fields, only: [:update], controller: 'entries/richtext_fields', param: :api_identifier
          resources :media_asset_fields, only: [:update], controller: 'entries/media_asset_fields', param: :api_identifier
        end
        resources :entries, only: :show, controller: 'entries/show'

        post 'entries/:content_entry_id/publication', to: 'publications#create', as: :entry_publication
        delete 'entries/:content_entry_id/publication', to: 'publications#destroy'
      end

      scope module: :singleton, as: :singleton do
        resource :entry, only: [:edit, :update], controller: 'entries/edit'
        resource :entry, only: :show, controller: 'entries/show'

        post 'entry/publication', to: 'publications#create', as: :entry_publication
      end
    end
  end

  resources :media, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      post :upload
    end
  end
  resources :categories, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  # ContentType management
  resources :content_types do
    resources :fields, controller: 'content_types/fields', except: [:index, :show]
    post 'fields/sort', to: 'content_types/fields#sort', as: :sort_fields
  end
end
