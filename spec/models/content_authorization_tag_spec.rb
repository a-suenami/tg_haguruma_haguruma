# typed: false
# frozen_string_literal: true

describe ContentAuthorizationTag do
  let(:tenant) { create(:tenant, id: 'sample') }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      tag = build(:content_authorization_tag, tenant_id: tenant.id)
      expect(tag).to be_valid
    end

    it 'requires a name' do
      tag = build(:content_authorization_tag, tenant_id: tenant.id, name: nil)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end

    it 'requires unique name within tenant' do
      create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium')
      tag = build(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium')
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include('has already been taken')
    end

    it 'allows same name in different tenants' do
      other_tenant = create(:tenant, id: 'other')
      create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium')

      Tenant.current_id = other_tenant.id
      tag = build(:content_authorization_tag, tenant_id: other_tenant.id, name: 'Premium')
      expect(tag).to be_valid
    end

    it 'allows nil remote_id' do
      tag = build(:content_authorization_tag, tenant_id: tenant.id, remote_id: nil)
      expect(tag).to be_valid
    end

    it 'requires unique remote_id within tenant when present' do
      remote_uuid = SecureRandom.uuid
      create(:content_authorization_tag, tenant_id: tenant.id, remote_id: remote_uuid)
      tag = build(:content_authorization_tag, tenant_id: tenant.id, remote_id: remote_uuid)
      expect(tag).not_to be_valid
      expect(tag.errors[:remote_id]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'has many user_tags' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id)
      expect(tag).to respond_to(:user_tags)
    end

    it 'has many users through user_tags' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id)
      expect(tag).to respond_to(:users)
    end

    it 'has many content_entry_authorizations' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id)
      expect(tag).to respond_to(:content_entry_authorizations)
    end

    it 'destroys user_tags when destroyed' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id)
      user = create(:user, tenant_id: tenant.id)
      create(:user_tag, tenant_id: tenant.id, user:, content_authorization_tag: tag)

      expect { tag.destroy }.to change { UserTag.count }.by(-1)
    end
  end
end
