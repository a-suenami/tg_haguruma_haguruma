# typed: false
# frozen_string_literal: true

RSpec.describe ContentAuthorizationTags::UpsertByRemoteIdService do
  let(:tenant) { Tenant.create!(id: 'test-tenant', name: 'Test Tenant') }
  let(:submitted_at) { Time.current }

  describe '#execute' do
    context 'when tag does not exist' do
      it 'creates a new tag' do
        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'remote-123',
          name: 'New Tag',
          submitted_at: submitted_at,
        )

        expect { service.execute }.to change(ContentAuthorizationTag, :count).by(1)

        tag = ContentAuthorizationTag.last
        expect(tag.remote_id).to eq('remote-123')
        expect(tag.name).to eq('New Tag')
        expect(tag.tenant_id).to eq(tenant.id)
      end
    end

    context 'when tag already exists' do
      let!(:existing_tag) do
        ContentAuthorizationTag.create!(
          tenant: tenant,
          remote_id: 'remote-123',
          name: 'Old Name',
        )
      end

      it 'updates the existing tag' do
        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'remote-123',
          name: 'Updated Name',
          submitted_at: submitted_at,
        )

        expect { service.execute }.not_to change(ContentAuthorizationTag, :count)

        existing_tag.reload
        expect(existing_tag.name).to eq('Updated Name')
      end

      it 'skips update if submitted_at is older than existing record' do
        existing_tag.update!(updated_at: Time.current + 1.hour)
        old_submitted_at = Time.current - 1.day

        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'remote-123',
          name: 'Should Not Update',
          submitted_at: old_submitted_at,
        )

        service.execute
        existing_tag.reload
        expect(existing_tag.name).to eq('Old Name')
      end
    end

    context 'when validation fails' do
      let!(:existing_tag) do
        ContentAuthorizationTag.create!(
          tenant: tenant,
          remote_id: 'other-remote',
          name: 'Duplicate Name',
        )
      end

      it 'returns nil and logs error' do
        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'new-remote',
          name: 'Duplicate Name',
          submitted_at: submitted_at,
        )

        expect(Rails.logger).to receive(:error).with(/Failed to upsert tag/)
        expect(service.execute).to be_nil
      end
    end
  end
end
