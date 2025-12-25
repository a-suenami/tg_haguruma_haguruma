# frozen_string_literal: true

namespace :user_area, path: '' do
  # Session management routes
  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
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
    resources :blog, only: [:index, :show]
    resources :schedules, only: [:index, :show]
  end
end
