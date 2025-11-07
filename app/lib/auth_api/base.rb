# typed: strict
# frozen_string_literal: true

module AuthApi
  class Base
    extend T::Sig
    extend T::Helpers
    abstract!

    RETRY_OPTIONS = T.let({
      max: 3,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed],
    }.freeze, T::Hash[T.untyped, T.untyped],)

    sig { params(endpoint_base: String).void }
    def initialize(endpoint_base:)
      @conn = T.let(Faraday.new(
        url: endpoint_base,
      ) do |f|
        f.request :url_encoded
        f.request :retry, RETRY_OPTIONS
        f.response :raise_error
        f.response :json
      end, Faraday::Connection,)
    end

    sig { abstract.params(client_id: String, client_secret: String, scope: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_access_token(client_id:, client_secret:, scope:); end

    sig { abstract.params(uid: String, token: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_user(uid:, token:); end
  end
end
