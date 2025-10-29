Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /health_check that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'health_check' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

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

    resources :tenants do
      member do
        get :admin_area
      end

      resources :admins, except: [:show]
      resources :oauth_providers, only: [:index]
    end
  end

  # Admin Area routes
  draw :admin
end
