# frozen_string_literal: true

namespace :user_area, path: '' do
  # Preview route (for admin preview with token)
  get '/preview/:content_type/:id', to: 'preview#show', as: :preview_content

  # Session management routes
  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  get '/auth/start', to: 'sessions#create', as: :auth_start
  delete 'logout', to: 'sessions#destroy', as: :logout
  get '/auth/callback', to: 'sessions#callback', as: :callback
  get '/auth/failure', to: 'sessions#failure', as: :auth_failure

  # Development only: bypass authentication
  get '/dev/skip_auth', to: 'sessions#dev_skip_auth', as: :dev_skip_auth if Rails.env.development?

  # Top page (root for user area)
  # root to: 'top#index' # Original implementation
  root to: 'alpha/root#index' # Alpha implementation

  # Profile management
  resource :profile, only: [:show, :edit, :update]

  # Contents
  resources :contents, only: [:index, :show]

  # Alpha: Short-term implementation (to be replaced by dynamic page system)
  # See: docs/adr/20251225-user-area-alpha-namespace/ADR.ja.md
  scope module: :alpha do
    resources :news, only: [:index, :show]
    resources :tickets, only: [:index, :show]
    resources :blog, only: [:index, :show]
    resources :schedules, only: [:index, :show]
    resource :biography, only: [:show]
    resource :privilege, only: [:show]
  end

  # Catch-all route for 404 (must be at the end)
  match '*path', to: 'errors#not_found', via: :all
end
