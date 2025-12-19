# frozen_string_literal: true

# ==============================================================================
# config - routes - api
# ==============================================================================
namespace :api do
  namespace :v1 do
    resources :contents, only: [:index, :show]
  end
end
