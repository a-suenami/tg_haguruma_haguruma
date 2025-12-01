# typed: false
# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Idp', type: :request do
  let(:tenant) { Tenant.create!(id: 'test-tenant', name: 'Test Tenant') }

  let(:oauth_provider) do
    OauthProvider.create!(
      tenant: tenant,
      kind: 'user',
      client_id: 'test-client-id',
      client_secret: 'test-client-secret',
      endpoint_base: 'https://auth.example.com',
      scopes: 'openid profile email',
      session_expires_in: 7_776_000,
    )
  end

  before do
    Tenant.current_id = tenant.id
  end

  path '/api/v1/auth/idp/provider' do
    get 'Get OAuth provider information' do
      tags 'Authentication'
      description 'Returns the information necessary for the OAuth client to construct the Authorization URL'
      produces 'application/json'

      parameter name: 'X-Tenant-Id', in: :header, type: :string, required: true,
                description: 'Tenant ID'

      response '200', 'successful' do
        let(:'X-Tenant-Id') { tenant.id }

        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string },
                     attributes: {
                       type: :object,
                       properties: {
                         client_id: { type: :string },
                         endpoint_base: { type: :string },
                         scopes: { type: :string },
                       },
                       required: %w[client_id endpoint_base],
                     },
                   },
                 },
               },
               required: %w[data]

        before { oauth_provider }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['client_id']).to eq('test-client-id')
          expect(data['data']['attributes']['endpoint_base']).to eq('https://auth.example.com')
          expect(response.headers['Cache-Control']).to include('max-age=60')
        end
      end

      response '401', 'unauthorized when tenant has no oauth provider' do
        let(:'X-Tenant-Id') { tenant.id }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     type: { type: :string },
                     message: { type: :string },
                   },
                 },
               }

        # No oauth_provider created - should return 401 or similar error
        run_test!
      end
    end
  end

  path '/api/v1/auth/idp/session' do
    post 'Create session with ID token' do
      tags 'Authentication'
      description 'Verifies the ID token and creates a session'
      consumes 'application/json'
      produces 'application/json'

      parameter name: 'X-Tenant-Id', in: :header, type: :string, required: true,
                description: 'Tenant ID'
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          id_token: { type: :string, description: 'JWT ID token from IdP' },
        },
        required: %w[id_token],
      }

      response '200', 'successful' do
        let(:'X-Tenant-Id') { tenant.id }
        let(:body) { { id_token: 'valid-jwt-token' } }
        let(:user_uid) { 'user-123' }

        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string },
                     attributes: {
                       type: :object,
                       properties: {
                         created_at: { type: :string, format: 'date-time' },
                         expires_at: { type: :string, format: 'date-time' },
                       },
                       required: %w[created_at expires_at],
                     },
                   },
                 },
               },
               required: %w[data]

        before do
          oauth_provider

          # Mock the VerifyIdTokenService to return a decoded token
          allow_any_instance_of(Auth::IdPlatform::VerifyIdTokenService).to receive(:execute)
            .and_return({ 'sub' => user_uid })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']).to have_key('created_at')
          expect(data['data']['attributes']).to have_key('expires_at')

          # Verify user was created
          user = User.find_by(tenant_id: tenant.id, uid: user_uid)
          expect(user).to be_present
          expect(user.oauth_provider).to eq(oauth_provider)
        end
      end

      response '401', 'unauthorized with invalid token' do
        let(:'X-Tenant-Id') { tenant.id }
        let(:body) { { id_token: 'invalid-jwt-token' } }

        schema type: :object,
               properties: {
                 error: {
                   type: :object,
                   properties: {
                     type: { type: :string },
                     message: { type: :string },
                   },
                   required: %w[type message],
                 },
               },
               required: %w[error]

        before do
          oauth_provider

          # Mock the VerifyIdTokenService to raise an error
          allow_any_instance_of(Auth::IdPlatform::VerifyIdTokenService).to receive(:execute)
            .and_raise(JWT::DecodeError.new('Invalid token'))
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']['type']).to eq('authentication_error')
        end
      end
    end
  end
end
