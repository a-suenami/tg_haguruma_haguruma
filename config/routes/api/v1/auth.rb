# ==============================================================================
# config - routes - api - v1 - auth routes
# ==============================================================================
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        scope :idp do
          # namespace for TwoGate's IdP
          # (OAuth2.0-OIDC along with id-platform.net)
          get :provider, to: 'idp#provider'
          post :session, to: 'idp#session'
        end
      end
    end
  end
end
