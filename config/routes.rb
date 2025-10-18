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

    # 動的なコンテンツタイプルーティング
    # コレクション型: /admin/contents/:content_type_id
    # シングル型: /admin/contents/single/:content_type_id
    get 'contents/:content_type_id', to: 'content_entries#index', as: :content_type_entries
    get 'contents/:content_type_id/new', to: 'content_entries#new', as: :new_content_type_entry
    get 'contents/:content_type_id/:id', to: 'content_entries#show', as: :content_type_entry
    get 'contents/:content_type_id/:id/edit', to: 'content_entries#edit', as: :edit_content_type_entry
    post 'contents/:content_type_id', to: 'content_entries#create'
    patch 'contents/:content_type_id/:id', to: 'content_entries#update'
    delete 'contents/:content_type_id/:id', to: 'content_entries#destroy'

    # シングル型コンテンツ専用
    get 'contents/single/:content_type_id', to: 'content_entries#show_single', as: :single_content_type

    # 従来の互換性用ルート（後で削除予定）
    resources :content_entries, only: [:index, :show, :new, :create, :edit, :update] do
      collection do
        get :content_types
      end
    end
    resources :content_models, only: [:index, :new, :edit]

    resources :media, only: [:index]
    resources :categories, only: [:index]
    get 'setting', to: 'setting#index'
  end
end
