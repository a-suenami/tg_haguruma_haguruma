# typed: false
# frozen_string_literal: true

describe ContentEntryAuthorization do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:content_type) { create(:content_type, tenant_id: tenant.id) }
  let(:content_entry) { create(:content_entry, tenant_id: tenant.id, content_type:) }
  let(:content_entry_version) { create(:content_entry_version, tenant_id: tenant.id, content_entry:) }
  let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id) }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      expect(authorization).to be_valid
    end

    it 'requires content_entry_id' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: nil,
        version: 1,
        content_authorization_tag: tag,
      )
      expect(authorization).not_to be_valid
      expect(authorization.errors[:content_entry_id]).to include("can't be blank")
    end

    it 'requires version' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry.id,
        version: nil,
        content_authorization_tag: tag,
      )
      expect(authorization).not_to be_valid
      expect(authorization.errors[:version]).to include("can't be blank")
    end

    it 'requires version to be greater than 0' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry.id,
        version: 0,
        content_authorization_tag: tag,
      )
      expect(authorization).not_to be_valid
      expect(authorization.errors[:version]).to include('must be greater than 0')
    end

    it 'requires unique tag per version within tenant' do
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      expect(authorization).not_to be_valid
      expect(authorization.errors[:content_authorization_tag_id]).to include('has already been taken')
    end

    it 'allows same tag on different versions' do
      other_version = create(
        :content_entry_version,
        tenant_id: tenant.id,
        content_entry:,
        version: 2,
      )
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: other_version.content_entry_id,
        version: other_version.version,
        content_authorization_tag: tag,
      )
      expect(authorization).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to content_entry_version' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      expect(authorization.content_entry_version).to eq(content_entry_version)
    end

    it 'belongs to content_authorization_tag' do
      authorization = build(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      expect(authorization.content_authorization_tag).to eq(tag)
    end
  end
end
