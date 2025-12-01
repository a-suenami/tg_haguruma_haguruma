# frozen_string_literal: true

# ==============================================================================
# config - routes - api
# ==============================================================================
namespace :api do
  resources :contents, only: [:index, :show]
end
