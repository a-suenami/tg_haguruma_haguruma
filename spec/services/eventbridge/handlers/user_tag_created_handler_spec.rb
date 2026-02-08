# typed: false

require 'rails_helper'

describe Eventbridge::Handlers::UserTagCreatedHandler do
  let(:tenant) { create(:tenant) }
  let(:handler) { described_class.new }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#handle' do
    let(:detail) do
      {
        'resource' => { 'id' => 'tag-abc-123', 'name' => 'VIPメンバー' },
      }
    end

    it 'creates a new ContentAuthorizationTag with provider idp' do
      expect { handler.handle(detail) }.to change { ContentAuthorizationTag.count }.by(1)

      tag = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: 'tag-abc-123')
      expect(tag).to be_present
      expect(tag.name).to eq('VIPメンバー')
      expect(tag.tenant_id).to eq(tenant.id)
    end

    it 'updates existing tag name when unique_id already exists' do
      create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-abc-123', name: '旧名称')

      expect { handler.handle(detail) }.not_to change { ContentAuthorizationTag.count }

      tag = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: 'tag-abc-123')
      expect(tag.name).to eq('VIPメンバー')
    end

    it 'is idempotent when called multiple times' do
      handler.handle(detail)
      expect { handler.handle(detail) }.not_to change { ContentAuthorizationTag.count }
    end

    it 'does nothing when resource is missing' do
      expect { handler.handle({}) }.not_to change { ContentAuthorizationTag.count }
    end

    it 'does nothing when resource id is blank' do
      bad_detail = { 'resource' => { 'id' => '', 'name' => 'Test' } }
      expect { handler.handle(bad_detail) }.not_to change { ContentAuthorizationTag.count }
    end

    it 'does nothing when resource name is blank' do
      bad_detail = { 'resource' => { 'id' => 'tag-123', 'name' => '' } }
      expect { handler.handle(bad_detail) }.not_to change { ContentAuthorizationTag.count }
    end

    it 'logs error when name conflicts with existing tag' do
      create(:content_authorization_tag, tenant_id: tenant.id, name: 'VIPメンバー')

      allow(Rails.logger).to receive(:error)

      handler.handle(detail)

      expect(Rails.logger).to have_received(:error).with(/failed to save tag/)
    end
  end
end
