# typed: false

require 'rails_helper'

describe Eventbridge::Handlers::TagRemovedHandler do
  let(:tenant) { create(:tenant) }
  let(:handler) { described_class.new }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#handle' do
    let(:user) { create(:user, tenant:) }
    let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-abc') }

    let(:detail) do
      {
        'resource' => { 'uid' => user.uid },
        'event_data' => { 'tag_id' => tag.unique_id },
      }
    end

    it 'destroys the UserTag' do
      create(:user_tag, tenant_id: tenant.id, user:, content_authorization_tag: tag)

      expect { handler.handle(detail) }.to change { UserTag.count }.by(-1)
    end

    it 'is idempotent when tag is already removed' do
      expect { handler.handle(detail) }.not_to change { UserTag.count }
    end

    it 'does nothing when user is not found' do
      bad_detail = {
        'resource' => { 'uid' => 'nonexistent-uid' },
        'event_data' => { 'tag_id' => tag.unique_id },
      }

      expect { handler.handle(bad_detail) }.not_to change { UserTag.count }
    end

    it 'does nothing when tag is not found' do
      bad_detail = {
        'resource' => { 'uid' => user.uid },
        'event_data' => { 'tag_id' => 'nonexistent-tag' },
      }

      create(:user_tag, tenant_id: tenant.id, user:, content_authorization_tag: tag)

      expect { handler.handle(bad_detail) }.not_to change { UserTag.count }
    end

    it 'does nothing when resource is missing' do
      expect { handler.handle({}) }.not_to change { UserTag.count }
    end

    it 'does nothing when uid is blank' do
      bad_detail = {
        'resource' => { 'uid' => '' },
        'event_data' => { 'tag_id' => tag.unique_id },
      }

      expect { handler.handle(bad_detail) }.not_to change { UserTag.count }
    end
  end
end
