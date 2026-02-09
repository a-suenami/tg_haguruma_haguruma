# typed: false

require 'rails_helper'

describe Eventbridge::Processors::IdpProcessor do
  let(:tenant) { create(:tenant) }
  let(:processor) { described_class.new(tenant_id: tenant.id) }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#process' do
    let(:source) { "com.twogate.idp/#{tenant.id}/user_tags" }

    it 'sets tenant context and dispatches to handler' do
      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'created.v1',
        source:,
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: {
          'resource' => { 'id' => 'tag-123', 'name' => 'VIP' },
        },
      )

      expect { processor.process(message) }.to change { ContentAuthorizationTag.count }.by(1)

      tag = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: 'tag-123')
      expect(tag).to be_present
      expect(tag.name).to eq('VIP')
    end

    it 'restores previous tenant context after processing' do
      original_tenant = create(:tenant)
      Tenant.current_id = original_tenant.id

      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'created.v1',
        source:,
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: {
          'resource' => { 'id' => 'tag-456', 'name' => 'Premium' },
        },
      )

      processor.process(message)

      expect(Tenant.current_id).to eq(original_tenant.id)
    end

    it 'clears tenant context when it was unset before processing' do
      RequestStore.store.delete(:current_tenant)

      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'created.v1',
        source:,
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: {
          'resource' => { 'id' => 'tag-789', 'name' => 'Test' },
        },
      )

      processor.process(message)

      expect(Tenant.current_id).to be_blank
    end

    it 'does nothing when detail is nil' do
      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'created.v1',
        source:,
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: nil,
      )

      expect { processor.process(message) }.not_to change { ContentAuthorizationTag.count }
    end

    it 'dispatches tag.added.v1 to TagAddedHandler' do
      create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-abc')
      user = create(:user, tenant:)

      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'tag.added.v1',
        source: "com.twogate.idp/#{tenant.id}/users",
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: {
          'resource' => { 'uid' => user.uid },
          'event_data' => { 'tag_id' => 'tag-abc' },
        },
      )

      expect { processor.process(message) }.to change { UserTag.count }.by(1)
    end

    it 'dispatches tag.removed.v1 to TagRemovedHandler' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-xyz')
      user = create(:user, tenant:)
      create(:user_tag, tenant_id: tenant.id, user:, content_authorization_tag: tag)

      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'tag.removed.v1',
        source: "com.twogate.idp/#{tenant.id}/users",
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: {
          'resource' => { 'uid' => user.uid },
          'event_data' => { 'tag_id' => 'tag-xyz' },
        },
      )

      expect { processor.process(message) }.to change { UserTag.count }.by(-1)
    end

    it 'logs warning for unknown detail_type' do
      allow(Rails.logger).to receive(:warn)

      message = Eventbridge::MessageParam.new(
        version: '0',
        id: SecureRandom.uuid,
        detail_type: 'unknown.event.v1',
        source:,
        account: '123456789',
        time: Time.current.iso8601,
        region: 'ap-northeast-1',
        resources: [],
        detail: { 'resource' => { 'id' => 'tag-999' } },
      )

      expect { processor.process(message) }.not_to change { ContentAuthorizationTag.count }
      expect(Rails.logger).to have_received(:warn).with(/unknown detail_type=unknown\.event\.v1/)
    end
  end
end
