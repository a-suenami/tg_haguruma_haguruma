# typed: false
# frozen_string_literal: true

require 'swagger_helper'

# rubocop:disable RSpec/EmptyExampleGroup, RSpec/ScatteredSetup
RSpec.describe 'Api::V1::Contents' do
  path '/api/v1/contents' do
    get 'List published content entries' do
      tags 'Contents'
      produces 'application/json'
      parameter name: :content_type,
                in: :query,
                type: :string,
                required: false,
                description: 'Filter by content type unique_name (e.g., "article", "announcement")'

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { '$ref' => '#/components/schemas/ContentEntry' },
                 },
               },
               required: ['data']

        let(:tenant) { create(:tenant, id: 'test-tenant') }

        before do
          Tenant.current_id = tenant.id
          host! "#{tenant.id}.api.example.com"
        end

        run_test!
      end
    end
  end

  path '/api/v1/contents/{id}' do
    get 'Get a published content entry' do
      tags 'Contents'
      produces 'application/json'
      parameter name: :id,
                in: :path,
                type: :string,
                format: :uuid,
                required: true,
                description: 'Content entry ID'

      response '200', 'successful' do
        schema '$ref' => '#/components/schemas/ContentEntryResponse'

        let(:tenant) { create(:tenant, id: 'test-tenant') }
        let(:content_type) { create(:content_type, tenant:) }
        let(:content_entry) { create(:content_entry, :published, tenant:, content_type:) }
        let(:id) { content_entry.id }

        before do
          Tenant.current_id = tenant.id
          host! "#{tenant.id}.api.example.com"
        end

        run_test!
      end

      response '404', 'not found' do
        schema '$ref' => '#/components/schemas/Error'

        let(:tenant) { create(:tenant, id: 'test-tenant') }
        let(:id) { '00000000-0000-0000-0000-000000000000' }

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
