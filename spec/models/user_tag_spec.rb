# typed: false
# frozen_string_literal: true

describe UserTag do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:user) { create(:user, tenant_id: tenant.id) }
  let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id) }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user_tag = build(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      expect(user_tag).to be_valid
    end

    it 'requires unique user_id per tag within tenant' do
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      user_tag = build(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      expect(user_tag).not_to be_valid
      expect(user_tag.errors[:user_id]).to include('has already been taken')
    end

    it 'allows same user to have different tags' do
      other_tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Other')
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      user_tag = build(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: other_tag)
      expect(user_tag).to be_valid
    end

    it 'allows different users to have same tag' do
      other_user = create(:user, tenant_id: tenant.id)
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      user_tag = build(:user_tag, tenant_id: tenant.id, user: other_user, content_authorization_tag: tag)
      expect(user_tag).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      user_tag = build(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      expect(user_tag.user).to eq(user)
    end

    it 'belongs to content_authorization_tag' do
      user_tag = build(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      expect(user_tag.content_authorization_tag).to eq(tag)
    end
  end
end
