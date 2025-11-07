# typed: strict
# frozen_string_literal: true

# auth service for id-platform.net
module Auth
  module IdPlatform
    class VerifyIdTokenService < BaseService
      extend T::Sig
      include JwtVerificationConcern

      ISSUER = T.let('auth-platform', String) # hard coded for security reasons

      sig { params(oauth_provider: OauthProvider).void }
      def initialize(oauth_provider:)
        @oauth_provider = T.let(oauth_provider, OauthProvider)
        @api = T.let(AuthApi::IdPlatform.new(endpoint_base: oauth_provider.endpoint_base), AuthApi::IdPlatform)
      end

      sig { params(id_token_jwt: String).returns(T.untyped) }
      def execute(id_token_jwt:)
        jwks = fetch_and_cache_jwks(
          cache_key: jwk_cache_key,
          jwks_fetcher: -> { @api.fetch_jwks },
        )
        decode_and_verify_jwt(id_token_jwt, jwks, issuer: ISSUER, audience: @oauth_provider.client_id)
      end

      private

      sig { returns(String) }
      def jwk_cache_key
        "auth/tenants/#{@oauth_provider.tenant_id}/#{@oauth_provider.client_id}/jwks"
      end
    end
  end
end
