# Be sure to restart your server when you modify this file.

# Configure parameters to be partially matched (e.g. passw matches password) and filtered from the log file.
# Use this to limit dissemination of sensitive information.
# See the ActiveSupport::ParameterFilter documentation for supported notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc,
  # Database related
  :database_url, :db_password, :database_password,
  # AWS credentials
  :aws_access_key_id, :aws_secret_access_key, :aws_session_token,
  # API credentials
  :api_key, :api_secret, :client_secret, :auth_token, :access_token, :refresh_token,
  # Auth0
  :auth0_client_secret,
  # Generic credentials
  :credential, :bearer,
]
