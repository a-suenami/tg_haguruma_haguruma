# frozen_string_literal: true

# ==============================================================================
# config - routes - api
# ==============================================================================
namespace :api do
  namespace :v1 do
    resources :contents, only: [:index, :show]

    # Content Authorization Tags
    resources :content_authorization_tags, only: [:index, :show, :create, :update, :destroy]

    # User Tags
    resources :users, only: [] do
      resources :tags, controller: 'user_tags', only: [:index, :create, :destroy]
    end

    # Content Entry Version Authorizations
    resources :content_entries, only: [] do
      resources :versions, only: [] do
        resources :authorizations, controller: 'content_entry_authorizations', only: [:index, :create, :destroy]
      end
    end
  end
end
