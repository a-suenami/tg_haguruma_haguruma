# frozen_string_literal: true

# ==============================================================================
# config - routes - api
# ==============================================================================
namespace :api do
  namespace :v1 do
    get 'me', to: 'users#me'
    resources :contents, only: [:index, :show]
  end
end
