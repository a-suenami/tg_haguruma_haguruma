# typed: strict
# frozen_string_literal: true

module Preview
  class TokenService
    extend T::Sig

    class InvalidTokenError < StandardError; end
    class ExpiredTokenError < StandardError; end

    sig { returns(ActiveSupport::MessageVerifier) }
    def self.verifier
      secret = Settings.preview.secret_key || Rails.application.secret_key_base
      ActiveSupport::MessageVerifier.new(secret, digest: 'SHA256', serializer: JSON)
    end

    sig { params(content_entry_id: String, tenant_id: String, expires_at: T.nilable(Time)).returns(String) }
    def self.generate(content_entry_id:, tenant_id:, expires_at: nil)
      expires_at ||= Time.current + Settings.preview.expires_in.to_i.seconds
      payload = {
        content_entry_id: content_entry_id,
        tenant_id: tenant_id,
        expires_at: expires_at.iso8601,
      }
      verifier.generate(payload)
    end

    sig { params(token: String).returns(T::Hash[Symbol, T.untyped]) }
    def self.verify(token)
      payload = verifier.verify(token)
      expires_at = Time.iso8601(payload['expires_at'])

      raise ExpiredTokenError, 'Preview token has expired' if expires_at < Time.current

      payload.symbolize_keys
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      raise InvalidTokenError, 'Invalid preview token'
    end

    sig { params(token: String).returns(T::Boolean) }
    def self.valid?(token)
      verify(token)
      true
    rescue InvalidTokenError, ExpiredTokenError
      false
    end
  end
end
