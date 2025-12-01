# typed: false
# frozen_string_literal: true

describe Api::V1::ContentAuthorizationTagsController do
  let(:tenant) { create(:tenant, id: 'sample') }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'GET /api/v1/content_authorization_tags' do
    it 'returns all tags for the tenant' do
      tag1 = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium')
      tag2 = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Standard')

      get '/api/v1/content_authorization_tags', headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json.length).to eq(2)
      expect(json.pluck('name')).to contain_exactly('Premium', 'Standard')
    end
  end

  describe 'GET /api/v1/content_authorization_tags/:id' do
    it 'returns the tag' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium')

      get "/api/v1/content_authorization_tags/#{tag.id}", headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['name']).to eq('Premium')
    end

    it 'returns 404 for non-existent tag' do
      get '/api/v1/content_authorization_tags/non-existent-id', headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/content_authorization_tags' do
    it 'creates a new tag' do
      expect do
        post '/api/v1/content_authorization_tags',
             params: { content_authorization_tag: { name: 'New Tag' } },
             headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(ContentAuthorizationTag, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json['name']).to eq('New Tag')
    end

    it 'returns errors for invalid data' do
      post '/api/v1/content_authorization_tags',
           params: { content_authorization_tag: { name: '' } },
           headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:unprocessable_entity)
      json = response.parsed_body
      expect(json['errors']).to include("Name can't be blank")
    end
  end

  describe 'PATCH /api/v1/content_authorization_tags/:id' do
    it 'updates the tag' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Old Name')

      patch "/api/v1/content_authorization_tags/#{tag.id}",
            params: { content_authorization_tag: { name: 'New Name' } },
            headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      expect(tag.reload.name).to eq('New Name')
    end
  end

  describe 'DELETE /api/v1/content_authorization_tags/:id' do
    it 'deletes the tag' do
      tag = create(:content_authorization_tag, tenant_id: tenant.id)

      expect do
        delete "/api/v1/content_authorization_tags/#{tag.id}",
               headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(ContentAuthorizationTag, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
