# typed: strict
# frozen_string_literal: true

module AuthApi
  class IdPlatform < Base
    extend T::Sig

    sig { returns(T.untyped) }
    def fetch_jwks
      response = @conn.get('/oauth/discovery/keys')
      response.body
    end

    sig { override.params(client_id: String, client_secret: String, scope: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_access_token(client_id:, client_secret:, scope:)
      response = @conn.post('/oauth/token') do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          client_id:,
          client_secret:,
          grant_type: 'client_credentials',
          scope:,
        }.to_json
      end
      T.cast(response.body, T::Hash[T.untyped, T.untyped])
    end

    sig { override.params(uid: String, token: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_user(uid:, token:)
      response = @conn.get("/api/v1/admin/users/#{uid}") do |req|
        req.headers['Authorization'] = "Bearer #{token}"
      end
      T.cast(response.body, T::Hash[T.untyped, T.untyped])
    end
  end
end
