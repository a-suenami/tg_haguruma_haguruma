# typed: false
# frozen_string_literal: true

describe Api::V1::ContentEntryAuthorizationsController do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:content_type) { create(:content_type, tenant_id: tenant.id) }
  let(:content_entry) { create(:content_entry, tenant_id: tenant.id, content_type: content_type) }
  let(:content_entry_version) { create(:content_entry_version, tenant_id: tenant.id, content_entry: content_entry) }
  let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium') }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'GET /api/v1/content_entries/:content_entry_id/versions/:version_id/authorizations' do
    it 'returns all tags for the content version' do
      other_tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Standard')
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: other_tag,
      )

      get "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations",
          headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json.length).to eq(2)
      expect(json.pluck('name')).to contain_exactly('Premium', 'Standard')
    end

    it 'returns empty array when version has no tags' do
      get "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations",
          headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json).to eq([])
    end
  end

  describe 'POST /api/v1/content_entries/:content_entry_id/versions/:version_id/authorizations' do
    it 'assigns a tag to the content version' do
      expect do
        post "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations",
             params: { content_authorization_tag_id: tag.id },
             headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(ContentEntryAuthorization, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json['name']).to eq('Premium')
    end

    it 'returns errors for duplicate assignment' do
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )

      post "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations",
           params: { content_authorization_tag_id: tag.id },
           headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/content_entries/:content_entry_id/versions/:version_id/authorizations/:id' do
    it 'removes a tag from the content version' do
      create(
        :content_entry_authorization,
        tenant_id: tenant.id,
        content_entry_id: content_entry_version.content_entry_id,
        version: content_entry_version.version,
        content_authorization_tag: tag,
      )

      expect do
        delete "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations/#{tag.id}",
               headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(ContentEntryAuthorization, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 when authorization does not exist' do
      delete "/api/v1/content_entries/#{content_entry.id}/versions/#{content_entry_version.version}/authorizations/#{tag.id}",
             headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
