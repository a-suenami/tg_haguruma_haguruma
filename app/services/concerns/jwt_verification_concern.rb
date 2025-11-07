# typed: strict
# frozen_string_literal: true

module JwtVerificationConcern
  extend T::Sig

  sig { params(token: String, jwks_hash: T.untyped, issuer: String, audience: String).returns(T.untyped) }
  def decode_and_verify_jwt(token, jwks_hash, issuer:, audience:)
    jwks = JWT::JWK::Set.new(jwks_hash)
    jwks.filter! { |key| key[:use] == 'sig' }
    algorithms = jwks.pluck(:alg).compact.uniq
    JWT.decode(token, nil, true, {
      algorithms:,
      aud: audience,
      iss: [issuer],
      verify_aud: true,
      verify_expiration: true,
      verify_iss: true,
      jwks:,
    },)[0]
  end

  sig { params(cache_key: String, jwks_fetcher: T.proc.returns(T.untyped)).returns(T.untyped) }
  def fetch_and_cache_jwks(cache_key:, jwks_fetcher:)
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      jwks_fetcher.call
    end
  end
end
