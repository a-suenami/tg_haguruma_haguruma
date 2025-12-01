# typed: false
# frozen_string_literal: true

RSpec.describe Eventbridge::Processors::IdPlatformProcessor do
  let(:tenant) { Tenant.create!(id: 'test-tenant', name: 'Test Tenant') }
  let(:processor) { described_class.new }

  describe '#process' do
    context 'with Id Platform Tag event' do
      let(:submitted_at) { Time.current.iso8601 }

      describe 'create action' do
        let(:message) do
          Eventbridge::MessageParam.new(
            version: '0',
            id: 'test-id',
            detail_type: 'Id Platform Tag',
            source: 'id-platform.twogate',
            account: 'test-account',
            time: Time.current.iso8601,
            region: 'ap-northeast-1',
            resources: [],
            detail: {
              'tenant_id' => tenant.id,
              'tag_id' => 'remote-tag-123',
              'name' => 'Premium',
              'action_code' => 'create',
              'submitted_at' => submitted_at,
            },
          )
        end

        it 'creates a new content authorization tag' do
          expect { processor.process(message) }.to change(ContentAuthorizationTag, :count).by(1)

          tag = ContentAuthorizationTag.last
          expect(tag.tenant_id).to eq(tenant.id)
          expect(tag.remote_id).to eq('remote-tag-123')
          expect(tag.name).to eq('Premium')
        end
      end

      describe 'update action' do
        let!(:existing_tag) do
          ContentAuthorizationTag.create!(
            tenant: tenant,
            remote_id: 'remote-tag-123',
            name: 'Old Name',
          )
        end

        let(:message) do
          Eventbridge::MessageParam.new(
            version: '0',
            id: 'test-id',
            detail_type: 'Id Platform Tag',
            source: 'id-platform.twogate',
            account: 'test-account',
            time: Time.current.iso8601,
            region: 'ap-northeast-1',
            resources: [],
            detail: {
              'tenant_id' => tenant.id,
              'tag_id' => 'remote-tag-123',
              'name' => 'Updated Name',
              'action_code' => 'update',
              'submitted_at' => submitted_at,
            },
          )
        end

        it 'updates the existing tag' do
          expect { processor.process(message) }.not_to change(ContentAuthorizationTag, :count)

          existing_tag.reload
          expect(existing_tag.name).to eq('Updated Name')
        end
      end

      describe 'delete action' do
        let!(:existing_tag) do
          ContentAuthorizationTag.create!(
            tenant: tenant,
            remote_id: 'remote-tag-123',
            name: 'To Be Deleted',
          )
        end

        let(:message) do
          Eventbridge::MessageParam.new(
            version: '0',
            id: 'test-id',
            detail_type: 'Id Platform Tag',
            source: 'id-platform.twogate',
            account: 'test-account',
            time: Time.current.iso8601,
            region: 'ap-northeast-1',
            resources: [],
            detail: {
              'tenant_id' => tenant.id,
              'tag_id' => 'remote-tag-123',
              'action_code' => 'delete',
              'submitted_at' => submitted_at,
            },
          )
        end

        it 'deletes the tag' do
          expect { processor.process(message) }.to change(ContentAuthorizationTag, :count).by(-1)
          expect(ContentAuthorizationTag.find_by(remote_id: 'remote-tag-123')).to be_nil
        end
      end

      describe 'with missing required fields' do
        let(:message) do
          Eventbridge::MessageParam.new(
            version: '0',
            id: 'test-id',
            detail_type: 'Id Platform Tag',
            source: 'id-platform.twogate',
            account: 'test-account',
            time: Time.current.iso8601,
            region: 'ap-northeast-1',
            resources: [],
            detail: {
              'tenant_id' => tenant.id,
              'action_code' => 'create',
              'submitted_at' => submitted_at,
            },
          )
        end

        it 'does not create a tag when tag_id is missing' do
          expect { processor.process(message) }.not_to change(ContentAuthorizationTag, :count)
        end
      end

      describe 'with invalid submitted_at' do
        let(:message) do
          Eventbridge::MessageParam.new(
            version: '0',
            id: 'test-id',
            detail_type: 'Id Platform Tag',
            source: 'id-platform.twogate',
            account: 'test-account',
            time: Time.current.iso8601,
            region: 'ap-northeast-1',
            resources: [],
            detail: {
              'tenant_id' => tenant.id,
              'tag_id' => 'remote-tag-123',
              'name' => 'Test',
              'action_code' => 'create',
              'submitted_at' => 'invalid-date',
            },
          )
        end

        it 'does not create a tag' do
          expect { processor.process(message) }.not_to change(ContentAuthorizationTag, :count)
        end
      end
    end
  end
end
