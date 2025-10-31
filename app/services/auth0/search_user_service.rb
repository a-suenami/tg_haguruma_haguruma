# typed: strict
# frozen_string_literal: true

module Auth0
  # Search for Auth0 Database user by email (Username-Password-Authentication only)
  #
  # Note: This only searches for users in Auth0 Database connection.
  # It will NOT find users from Google OAuth, Facebook, or other social connections.
  #
  # Usage:
  #   service = Auth0::SearchUserService.new(email: 'user@example.com')
  #   result = service.execute
  #
  #   if result.is_a?(Mangrove::Result::Ok)
  #     user = result.unwrap # Auth0 Database user data
  #   else
  #     errors = result.unwrap_err
  #   end
  class SearchUserService < BaseService
    extend T::Sig

    sig { params(email: String).void }
    def initialize(email:)
      @email = email
    end

    sig { returns(Mangrove::Result[T::Hash[String, T.untyped], T::Array[String]]) }
    def execute
      # Only search for Database connection users (not Google OAuth, Facebook, etc.)
      query = "email:\"#{@email}\" AND identities.connection:\"Username-Password-Authentication\""
      users = client.users(q: query)

      if users.empty?
        Mangrove::Result::Err.new(T.let(['User not found'], T::Array[String]))
      else
        Mangrove::Result::Ok.new(T.must(users.first))
      end
    rescue Auth0::HTTPError => e
      Rails.logger.error("Auth0::SearchUserService error: HTTP #{e.http_code} - #{e.message}")

      # Map Auth0 API HTTP status codes to user-friendly messages
      error_message = case e.http_code
      when 401 # Unauthorized - Invalid M2M credentials
        'Auth0 API authentication failed. Please check credentials.'
      when 403 # Forbidden - Missing required scopes
        'Auth0 API access forbidden. Please check read:users scope.'
      when 429 # Too Many Requests - Rate limit exceeded
        'Auth0 API rate limit exceeded. Please try again later.'
      else
        # For other HTTP errors, use raw message
        e.message
      end

      Mangrove::Result::Err.new(T.let([error_message], T::Array[String]))
    end
  end
end
