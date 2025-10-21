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
  # Admin Auth0 Provider
  # ----------------------------------------------------------------------------
  # Used for admin area authentication (tenant administrators)
  # Callback URL: /admin/auth/auth0/callback
  # Tenant is detected from subdomain (e.g., sample.idp.localhost:3000)
  # NOTE: Uses same :auth0 strategy with different callback path
  provider(
    :auth0,
    Settings.auth0.admin.client_id,
    Settings.auth0.admin.client_secret,
    Settings.auth0.admin.domain,
    callback_path: '/admin/auth/auth0/callback',
    path_prefix: '/admin/auth',
    authorize_params: {
      scope: 'openid profile email',
      prompt: 'login', # Always show login screen (disable SSO)
    },
  )
end

# ------------------------------------------------------------------------------
# OmniAuth Configuration
# ------------------------------------------------------------------------------

# Use Rails logger for OmniAuth (unified logging)
OmniAuth.config.logger = Rails.logger
