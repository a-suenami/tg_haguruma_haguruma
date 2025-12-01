# typed: false
# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Auth::Idp', type: :request do
  path '/api/v1/auth/idp/provider' do
    get 'Get OAuth provider information' do
      tags 'Authentication'
      description 'Returns the information necessary for the OAuth client to construct the Authorization URL'
      produces 'application/json'

      parameter name: 'X-Tenant-Id', in: :header, type: :string, required: true,
                description: 'Tenant ID'

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 provider_type: { type: :string },
                 client_id: { type: :string },
                 authorization_endpoint: { type: :string },
                 scope: { type: :string },
               },
               required: %w[id name provider_type client_id authorization_endpoint]

        run_test!
      end

      response '401', 'unauthorized' do
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
        schema type: :object,
               properties: {
                 access_token: { type: :string },
                 token_type: { type: :string },
                 expires_in: { type: :integer },
               },
               required: %w[access_token token_type expires_in]

        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end
  end
end
