# frozen_string_literal: true

# Swagger UI and API docs (ruler domain only)
mount Rswag::Ui::Engine => '/api-docs'
mount Rswag::Api::Engine => '/api-docs'

root to: redirect('/ruler'), as: :ruler_root_redirect

namespace :ruler_area, path: :ruler do
  # Auth0 Authentication routes
  get 'login', to: 'auth0#login', as: :login
  get 'logout', to: 'auth0#logout', as: :logout
  get '/auth/auth0/callback', to: 'auth0#callback'
  get '/auth/failure', to: 'auth0#failure'

  root to: 'tenants#index', as: :root

  # Flipper UI (advanced feature flag management)
  flipper_constraint = ->(request) { request.session[:ruler_id].present? }
  constraints flipper_constraint do
    mount Flipper::UI.app(Flipper) => '/flipper'
  end

  # Profile management
  resource :profiles, only: [:edit, :update]

  # Ruler management
  resources :rulers, except: [:show]

  # Global Feature Flags (all tenants)
  resources :global_feature_flags, only: [:index], path: 'feature-flags' do
    member do
      post :toggle
    end
  end

  resources :tenants do
    member do
      get :admin_area
    end

    resources :admins, except: [:show]
    resources :oauth_providers, except: [:show]
    resources :content_types, except: [:edit, :destroy]
    resources :authorization_tags, except: [:show]
    resources :users, only: [:index, :show, :new, :create, :destroy] do
      resources :user_tags, only: [:create, :destroy]
      resources :session_tokens, only: [:index, :create, :destroy]
    end

    # Site settings
    resource :site_setting, only: [:show, :edit, :update]
    resource :theme, only: [:show, :edit, :update]
    resource :basic_auth, only: [:show, :update] do
      resources :credentials, controller: 'basic_auth_credentials', only: [:new, :create, :edit, :update, :destroy]
    end
    resources :pages, only: [:index]
    resources :custom_variables, except: [:show] do
      member do
        get :edit_value
        patch :update_value
      end
    end

    # Feature Flags (per tenant)
    resources :feature_flags, only: [:index] do
      member do
        post :toggle
      end
    end
  end
end
