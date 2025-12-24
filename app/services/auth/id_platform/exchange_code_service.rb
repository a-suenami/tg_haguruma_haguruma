# typed: strict
# frozen_string_literal: true

module Auth
  module IdPlatform
    class ExchangeCodeService < BaseService
      extend T::Sig

      class Result < T::Struct
        const :id_token, String
        const :access_token, String
        const :token_type, String
        const :expires_in, Integer
      end

      class Error < StandardError; end

      sig { params(oauth_provider: OauthProvider).void }
      def initialize(oauth_provider:)
        @oauth_provider = T.let(oauth_provider, OauthProvider)
        @api = T.let(AuthApi::IdPlatform.new(endpoint_base: oauth_provider.endpoint_base), AuthApi::IdPlatform)
      end

      sig { params(code: String, redirect_uri: String).returns(Result) }
      def execute(code:, redirect_uri:)
        response = @api.exchange_code(
          client_id: @oauth_provider.client_id,
          client_secret: T.must(@oauth_provider.client_secret),
          code:,
          redirect_uri:,
        )

        Result.new(
          id_token: response['id_token'],
          access_token: response['access_token'],
          token_type: response['token_type'] || 'Bearer',
          expires_in: response['expires_in'] || 3600,
        )
      rescue Faraday::Error => e
        raise Error.new("Failed to exchange code: #{e.message}")
      end
    end
  end
end
