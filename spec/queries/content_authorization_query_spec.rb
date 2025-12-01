# typed: false
# frozen_string_literal: true

describe ContentAuthorizationQuery do
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
        query = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(query.authorized?).to be true
      end

      it 'returns true for nil user (unauthenticated)' do
        query = described_class.new(user: nil, content_entry_version: content_entry_version)
        expect(query.authorized?).to be true
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
        query = described_class.new(user: nil, content_entry_version: content_entry_version)
        expect(query.authorized?).to be false
      end

      it 'returns false for user without matching tag' do
        query = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(query.authorized?).to be false
      end

      it 'returns true for user with matching tag' do
        create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)

        query = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(query.authorized?).to be true
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

        query = described_class.new(user: user, content_entry_version: content_entry_version)
        expect(query.authorized?).to be true
      end
    end
  end
end
