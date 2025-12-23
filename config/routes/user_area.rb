# frozen_string_literal: true

namespace :user_area, path: '' do
  # Session management routes
  get 'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy', as: :logout
  get '/auth/callback', to: 'sessions#callback', as: :callback
  get '/auth/failure', to: 'sessions#failure', as: :auth_failure

  # Top page (root for user area)
  root to: 'top#index'

  # Profile management
  resource :profile, only: [:show, :edit, :update]

  # Contents
  resources :contents, only: [:index, :show]
end
