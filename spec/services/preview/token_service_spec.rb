# typed: false
# frozen_string_literal: true

describe Preview::TokenService do
  let(:content_entry_id) { SecureRandom.uuid }
  let(:tenant_id) { 'sample' }

  describe '.generate' do
    it 'generates a token string' do
      token = described_class.generate(content_entry_id:, tenant_id:)
      expect(token).to be_a(String)
      expect(token).not_to be_empty
    end

    it 'generates different tokens for different content entries' do
      token1 = described_class.generate(content_entry_id:, tenant_id:)
      token2 = described_class.generate(content_entry_id: SecureRandom.uuid, tenant_id:)
      expect(token1).not_to eq(token2)
    end

    it 'allows custom expiration time' do
      custom_expires_at = 2.hours.from_now
      token = described_class.generate(content_entry_id:, tenant_id:, expires_at: custom_expires_at)
      payload = described_class.verify(token)
      expect(Time.iso8601(payload[:expires_at].to_s)).to be_within(1.second).of(custom_expires_at)
    end
  end

  describe '.verify' do
    it 'returns payload with content_entry_id and tenant_id' do
      token = described_class.generate(content_entry_id:, tenant_id:)
      payload = described_class.verify(token)

      expect(payload[:content_entry_id]).to eq(content_entry_id)
      expect(payload[:tenant_id]).to eq(tenant_id)
    end

    it 'raises InvalidTokenError for tampered token' do
      token = described_class.generate(content_entry_id:, tenant_id:)
      tampered_token = token + 'tampered'

      expect { described_class.verify(tampered_token) }
        .to raise_error(Preview::TokenService::InvalidTokenError)
    end

    it 'raises ExpiredTokenError for expired token' do
      token = described_class.generate(content_entry_id:, tenant_id:, expires_at: 1.second.ago)

      expect { described_class.verify(token) }
        .to raise_error(Preview::TokenService::ExpiredTokenError)
    end

    it 'raises InvalidTokenError for invalid string' do
      expect { described_class.verify('invalid_token') }
        .to raise_error(Preview::TokenService::InvalidTokenError)
    end
  end

  describe '.valid?' do
    it 'returns true for valid token' do
      token = described_class.generate(content_entry_id:, tenant_id:)
      expect(described_class.valid?(token)).to be true
    end

    it 'returns false for expired token' do
      token = described_class.generate(content_entry_id:, tenant_id:, expires_at: 1.second.ago)
      expect(described_class.valid?(token)).to be false
    end

    it 'returns false for invalid token' do
      expect(described_class.valid?('invalid_token')).to be false
    end
  end
end
