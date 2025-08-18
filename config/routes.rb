Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # Ruler Area routes
  namespace :ruler_area, path: :ruler do
    root to: 'tenants#index', as: :root

    resources :tenants do
      member do
        get :admin_area
      end

      # Sidebar navigation routes (placeholder controllers)
      resources :admins, only: [:index]
      resources :oauth_providers, only: [:index]
    end
  end

  # Admin Area routes
  namespace :admin_area, path: :admin do
    root to: 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'

    resources :content_entries, only: [:index, :new, :create, :edit, :update]
    resources :content_models, only: [:index, :new, :edit]

    resources :media, only: [:index]
    resources :categories, only: [:index]
    get 'setting', to: 'setting#index'
  end
end
