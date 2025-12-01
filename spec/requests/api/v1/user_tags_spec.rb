# typed: false
# frozen_string_literal: true

describe Api::V1::UserTagsController do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:user) { create(:user, tenant_id: tenant.id) }
  let(:tag) { create(:content_authorization_tag, tenant_id: tenant.id, name: 'Premium') }

  before do
    Tenant.current_id = tenant.id
  end

  describe 'GET /api/v1/users/:user_id/tags' do
    it 'returns all tags for the user' do
      other_tag = create(:content_authorization_tag, tenant_id: tenant.id, name: 'Standard')
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: other_tag)

      get "/api/v1/users/#{user.id}/tags", headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json.length).to eq(2)
      expect(json.pluck('name')).to contain_exactly('Premium', 'Standard')
    end

    it 'returns empty array when user has no tags' do
      get "/api/v1/users/#{user.id}/tags", headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json).to eq([])
    end
  end

  describe 'POST /api/v1/users/:user_id/tags' do
    it 'assigns a tag to the user' do
      expect do
        post "/api/v1/users/#{user.id}/tags",
             params: { content_authorization_tag_id: tag.id },
             headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(UserTag, :count).by(1)

      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json['name']).to eq('Premium')
    end

    it 'returns errors for duplicate assignment' do
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)

      post "/api/v1/users/#{user.id}/tags",
           params: { content_authorization_tag_id: tag.id },
           headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /api/v1/users/:user_id/tags/:id' do
    it 'removes a tag from the user' do
      create(:user_tag, tenant_id: tenant.id, user: user, content_authorization_tag: tag)

      expect do
        delete "/api/v1/users/#{user.id}/tags/#{tag.id}",
               headers: { 'Host' => "#{tenant.id}.example.com" }
      end.to change(UserTag, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 when user tag does not exist' do
      delete "/api/v1/users/#{user.id}/tags/#{tag.id}",
             headers: { 'Host' => "#{tenant.id}.example.com" }

      expect(response).to have_http_status(:not_found)
    end
  end
end
