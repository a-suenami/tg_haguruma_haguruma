# typed: false
# frozen_string_literal: true

RSpec.describe ContentAuthorizationTags::DeleteByRemoteIdService do
  let(:tenant) { Tenant.create!(id: 'test-tenant', name: 'Test Tenant') }
  let(:submitted_at) { Time.current }

  describe '#execute' do
    context 'when tag exists' do
      let!(:existing_tag) do
        ContentAuthorizationTag.create!(
          tenant: tenant,
          remote_id: 'remote-123',
          name: 'To Delete',
        )
      end

      it 'deletes the tag and returns true' do
        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'remote-123',
          submitted_at: submitted_at,
        )

        expect { service.execute }.to change(ContentAuthorizationTag, :count).by(-1)
        expect(ContentAuthorizationTag.find_by(remote_id: 'remote-123')).to be_nil
      end

      it 'skips delete if submitted_at is older than existing record' do
        existing_tag.update!(updated_at: Time.current + 1.hour)
        old_submitted_at = Time.current - 1.day

        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'remote-123',
          submitted_at: old_submitted_at,
        )

        expect(service.execute).to be false
        expect(ContentAuthorizationTag.find_by(remote_id: 'remote-123')).to be_present
      end
    end

    context 'when tag does not exist' do
      it 'returns false' do
        service = described_class.new(
          tenant_id: tenant.id,
          remote_id: 'non-existent',
          submitted_at: submitted_at,
        )

        expect(service.execute).to be false
      end
    end
  end
end
