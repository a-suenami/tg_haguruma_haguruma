Rails.application.routes.draw do
  # Swagger UI and API docs
  # - Development/Test: always accessible
  # - Production: only accessible from ruler.* subdomain
  if Rails.env.development? || Rails.env.test?
    mount Rswag::Ui::Engine => '/api-docs'
    mount Rswag::Api::Engine => '/api-docs'
  else
    constraints subdomain: /\Aruler\./ do
      mount Rswag::Ui::Engine => '/api-docs'
      mount Rswag::Api::Engine => '/api-docs'
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /health_check that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'health_check' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Redirect based on subdomain: ruler.* -> /ruler, admin.* -> /admin
  root to: 'root#index'

  # Ruler Area routes
  namespace :ruler_area, path: :ruler do
    # Auth0 Authentication routes
    get 'login', to: 'auth0#login', as: :login
    get 'logout', to: 'auth0#logout', as: :logout
    get '/auth/auth0/callback', to: 'auth0#callback'
    get '/auth/failure', to: 'auth0#failure'

    root to: 'tenants#index', as: :root

    # Profile management
    resource :profiles, only: [:edit, :update]

    # Ruler management
    resources :rulers, except: [:show]

    resources :tenants do
      member do
        get :admin_area
      end

      resources :admins, except: [:show]
      resources :oauth_providers, except: [:show]
      resources :content_types, except: [:edit, :destroy]
    end
  end

  # Admin Area routes
  draw :admin

  # API routes
  draw :'api/v1/auth'
  draw :api

  # Test routes (only available in test environment or when ALLOW_AUTH_BYPASS is enabled)
  if Rails.env.test? || Rails.env.development? || ENV['ALLOW_AUTH_BYPASS'] == 'true'
    namespace :test do
      get 'auth/bypass', to: 'auth#bypass'
    end
  end
end
