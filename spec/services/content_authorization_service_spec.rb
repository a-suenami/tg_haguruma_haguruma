# typed: false
# frozen_string_literal: true

describe ContentAuthorizationService do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:content_type) { create(:content_type, tenant_id: tenant.id) }
  let(:content_entry) { create(:content_entry, tenant_id: tenant.id, content_type: content_type) }
  let(:content_entry_version) { create(:content_entry_version, tenant_id: tenant.id, content_entry: content_entry) }
  let(:user) { create(:user, tenant_id: tenant.id) }
  let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium') }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#authorized?' do
    context 'when content has no authorization tags' do
      it 'returns true for any user' do
        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(service.authorized?).to be true
      end

      it 'returns true for nil user (unauthenticated)' do
        service = described_class.new(user: nil, content_entry_version: content_entry_version)
        expect(service.authorized?).to be true
      end
    end

    context 'when content has authorization tags' do
      before do
        create(
          :content_entry_authorization,
          tenant_id: tenant.id,
          content_entry_id: content_entry_version.content_entry_id,
          version: content_entry_version.version,
          content_authorization_tag: tag,
        )
      end

      it 'returns false for nil user (unauthenticated)' do
        service = described_class.new(user: nil, content_entry_version: content_entry_version)
        expect(service.authorized?).to be false
      end

      it 'returns false for user without matching tag' do
        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(service.authorized?).to be false
      end

      it 'returns true for user with matching tag' do
        create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)

        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(service.authorized?).to be true
      end

      it 'returns true when user has one of multiple required tags' do
        other_tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Standard')
        create(
          :content_entry_authorization,
          tenant_id: tenant.id,
          content_entry_id: content_entry_version.content_entry_id,
          version: content_entry_version.version,
          content_authorization_tag: other_tag,
        )
        create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: other_tag)

        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(service.authorized?).to be true
      end
    end
  end

  describe '#authorize!' do
    context 'when authorized' do
      it 'does not raise an error' do
        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect { service.authorize! }.not_to raise_error
      end
    end

    context 'when not authorized' do
      before do
        create(
          :content_entry_authorization,
          tenant_id: tenant.id,
          content_entry_id: content_entry_version.content_entry_id,
          version: content_entry_version.version,
          content_authorization_tag: tag,
        )
      end

      it 'raises ContentAuthorizationError' do
        service = described_class.new(user: user, content_entry_version: content_entry_version)
        expect { service.authorize! }.to raise_error(described_class::ContentAuthorizationError)
      end
    end
  end
end
