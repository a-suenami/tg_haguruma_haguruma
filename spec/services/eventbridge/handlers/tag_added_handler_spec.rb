# typed: false

require 'rails_helper'

describe Eventbridge::Handlers::TagAddedHandler do
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

    it 'creates a UserTag linking user and tag' do
      expect { handler.handle(detail) }.to change { UserTag.count }.by(1)

      user_tag = UserTag.find_by(user:, content_authorization_tag: tag)
      expect(user_tag).to be_present
    end

    it 'is idempotent when called multiple times' do
      handler.handle(detail)
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

    it 'does nothing when tag_id is blank' do
      bad_detail = {
        'resource' => { 'uid' => user.uid },
        'event_data' => { 'tag_id' => '' },
      }

      expect { handler.handle(bad_detail) }.not_to change { UserTag.count }
    end
  end
end
