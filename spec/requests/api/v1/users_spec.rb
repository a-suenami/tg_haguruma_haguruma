# typed: false
# frozen_string_literal: true

require 'swagger_helper'

# rubocop:disable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
RSpec.describe 'Api::V1::Users' do
  path '/api/v1/me' do
    get 'Get current authenticated user information' do
      tags 'User'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 id: { type: :string, format: :uuid },
                 uid: { type: :string },
                 last_authenticated_at: { type: :string, format: :'date-time' },
                 authorization_tags: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       name: { type: :string },
                     },
                     required: %w[id name],
                   },
                 },
                 registered_at: { type: :string, format: :'date-time' },
               },
               required: %w[id uid last_authenticated_at authorization_tags registered_at]

        let(:tenant) { create(:tenant) }
        let(:user) { create(:user, tenant:) }
        let(:session_token) { create(:session_token, user:) }
        let(:Authorization) { "Bearer #{session_token.id}" }

        before do
          Tenant.current_id = tenant.id
          host! "#{tenant.id}.api.example.com"
        end

        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/Error'

        let(:tenant) { create(:tenant) }
        let(:Authorization) { '' }

        before do
          Tenant.current_id = tenant.id
          host! "#{tenant.id}.api.example.com"
        end

        run_test!
      end
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
