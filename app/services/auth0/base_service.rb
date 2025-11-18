# typed: strict
# frozen_string_literal: true

module Auth0
  # Base service for Auth0 Management API operations
  class BaseService
    extend T::Sig

    sig { returns(Auth0Client) }
    def client
      @client ||= T.let(
        Auth0Client.new(
          client_id: Settings.auth0.m2m.client_id,
          client_secret: Settings.auth0.m2m.client_secret,
          domain: Settings.auth0.m2m.domain,
          api_version: 2,
        ),
        T.nilable(Auth0Client),
      )
    end
  end
end
