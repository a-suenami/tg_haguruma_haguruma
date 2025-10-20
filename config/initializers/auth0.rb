# frozen_string_literal: true

# ==============================================================================
# Auth0 OmniAuth Configuration
# ==============================================================================
#
# This initializer configures OmniAuth to use Auth0 for authentication.
# It supports multiple Auth0 applications for different areas (ruler, admin).
# ==============================================================================

Rails.application.config.middleware.use OmniAuth::Builder do
  # ----------------------------------------------------------------------------
  # Ruler Auth0 Provider
  # ----------------------------------------------------------------------------
  # Used for ruler area authentication (super administrators)
  # Callback URL: /ruler/auth/auth0/callback
  provider(
    :auth0,
    Settings.auth0.ruler.client_id,
    Settings.auth0.ruler.client_secret,
    Settings.auth0.ruler.domain,
    callback_path: '/ruler/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile email',
      prompt: 'login', # Always show login screen (disable SSO)
    },
  )

  # ----------------------------------------------------------------------------
  # Admin Auth0 Provider (Coming Soon)
  # ----------------------------------------------------------------------------
  # TODO: Add admin provider when admin area authentication is implemented
  # provider(
  #   :auth0_admin,
  #   Settings.auth0.admin.client_id,
  #   Settings.auth0.admin.client_secret,
  #   Settings.auth0.admin.domain,
  #   callback_path: '/admin/auth/auth0/callback',
  #   authorize_params: {
  #     scope: 'openid profile email'
  #   }
  # )
end

# ------------------------------------------------------------------------------
# OmniAuth Configuration
# ------------------------------------------------------------------------------

# Use Rails logger for OmniAuth (unified logging)
OmniAuth.config.logger = Rails.logger
