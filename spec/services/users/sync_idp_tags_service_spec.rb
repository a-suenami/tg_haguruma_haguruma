# typed: false

require 'rails_helper'

describe Users::SyncIdpTagsService do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant:) }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#execute' do
    context 'when ContentAuthorizationTag already exists' do
      let!(:tag) { create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-123', name: 'VIP') }

      it 'creates UserTag for the user' do
        tags = [{ 'id' => 'tag-123', 'name' => 'VIP' }]

        expect { described_class.new(user:, tags:).execute }.to change { UserTag.count }.by(1)
      end

      it 'is idempotent' do
        tags = [{ 'id' => 'tag-123', 'name' => 'VIP' }]

        described_class.new(user:, tags:).execute
        expect { described_class.new(user:, tags:).execute }.not_to change { UserTag.count }
      end
    end

    context 'when ContentAuthorizationTag does not exist' do
      it 'creates ContentAuthorizationTag and UserTag' do
        tags = [{ 'id' => 'tag-new', 'name' => '年会費請求中' }]

        expect { described_class.new(user:, tags:).execute }
          .to change { ContentAuthorizationTag.count }.by(1)
          .and change { UserTag.count }.by(1)

        cat = ContentAuthorizationTag.find_by(provider: 'idp', unique_id: 'tag-new')
        expect(cat).to be_present
        expect(cat.name).to eq('年会費請求中')
      end

      it 'updates name if tag already exists with different name' do
        create(:content_authorization_tag, tenant_id: tenant.id, provider: 'idp', unique_id: 'tag-456', name: '旧名称')
        tags = [{ 'id' => 'tag-456', 'name' => '新名称' }]

        described_class.new(user:, tags:).execute

        expect(ContentAuthorizationTag.find_by(provider: 'idp', unique_id: 'tag-456').name).to eq('新名称')
      end
    end

    context 'with invalid tag data' do
      it 'skips tags with blank id' do
        tags = [{ 'id' => '', 'name' => 'Test' }]

        expect { described_class.new(user:, tags:).execute }.not_to change { UserTag.count }
      end

      it 'skips tags with blank name' do
        tags = [{ 'id' => 'tag-789', 'name' => '' }]

        expect { described_class.new(user:, tags:).execute }.not_to change { UserTag.count }
      end

      it 'skips tags with nil id' do
        tags = [{ 'name' => 'Test' }]

        expect { described_class.new(user:, tags:).execute }.not_to change { UserTag.count }
      end
    end
  end
end
