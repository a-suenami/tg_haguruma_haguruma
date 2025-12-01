# typed: false
# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Api::V1::Contents', type: :request do
  let(:tenant) { Tenant.create!(id: 'test-tenant', name: 'Test Tenant') }

  let(:content_type) do
    Tenant.current_id = tenant.id
    ContentType.create!(
      tenant: tenant,
      unique_name: 'articles',
      display_name: 'Articles',
      is_collection: true,
    )
  end

  let(:content_type_field) do
    ContentType::Field.create!(
      tenant: tenant,
      content_type: content_type,
      api_identifier: 'title',
      label: 'Title',
      field_type: :text,
      required: true,
      position: 0,
    )
  end

  let(:content_entry) do
    ContentEntry.create!(
      tenant: tenant,
      content_type: content_type,
    )
  end

  let(:field_text) do
    ContentEntry::FieldText.create!(value: 'Test Article Title')
  end

  let(:published_version) do
    ContentEntry::Version.create!(
      tenant_id: tenant.id,
      content_type_id: content_type.id,
      content_entry_id: content_entry.id,
      version: 1,
      status: :published,
      published_at: Time.current,
    )
  end

  let(:content_entry_field) do
    ContentEntry::Field.create!(
      tenant_id: tenant.id,
      content_type_id: content_type.id,
      content_entry_id: content_entry.id,
      version: published_version.version,
      content_type_field: content_type_field,
      field_type: :text,
      text: field_text,
    )
  end

  let(:setup_published_content) do
    content_type_field
    content_entry_field
  end

  before do
    Tenant.current_id = tenant.id
  end

  path '/api/v1/contents' do
    get 'List published content entries' do
      tags 'Contents'
      description 'Returns a list of all published content entries, optionally filtered by content type'
      produces 'application/json'

      parameter name: :content_type_id, in: :query, type: :string, required: false,
                description: 'Filter by content type ID'

      response '200', 'successful' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: {
                         type: :object,
                         properties: {
                           content_type: {
                             type: :object,
                             properties: {
                               id: { type: :string },
                               unique_name: { type: :string },
                               display_name: { type: :string },
                               is_collection: { type: :boolean },
                             },
                           },
                           fields: { type: :object },
                           published_at: { type: :string, format: 'date-time', nullable: true },
                           created_at: { type: :string, format: 'date-time' },
                           updated_at: { type: :string, format: 'date-time' },
                         },
                       },
                     },
                   },
                 },
               },
               required: %w[data]

        context 'when there are published content entries' do
          before { setup_published_content }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data']).to be_an(Array)
            expect(data['data'].length).to eq(1)
            expect(data['data'][0]['attributes']['fields']['title']).to eq('Test Article Title')
          end
        end

        context 'when filtered by content_type_id' do
          let(:content_type_id) { content_type.id }

          before { setup_published_content }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data']).to be_an(Array)
            expect(data['data'].length).to eq(1)
          end
        end

        context 'when no published content entries exist' do
          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['data']).to eq([])
          end
        end
      end
    end
  end

  path '/api/v1/contents/{id}' do
    get 'Get a published content entry' do
      tags 'Contents'
      description 'Returns a specific published content entry by ID'
      produces 'application/json'

      parameter name: :id, in: :path, type: :string, required: true,
                description: 'Content entry ID'

      response '200', 'successful' do
        let(:id) { content_entry.id }

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
                         content_type: {
                           type: :object,
                           properties: {
                             id: { type: :string },
                             unique_name: { type: :string },
                             display_name: { type: :string },
                             is_collection: { type: :boolean },
                           },
                         },
                         fields: { type: :object },
                         published_at: { type: :string, format: 'date-time', nullable: true },
                         created_at: { type: :string, format: 'date-time' },
                         updated_at: { type: :string, format: 'date-time' },
                       },
                     },
                   },
                 },
               },
               required: %w[data]

        before { setup_published_content }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['id']).to eq(content_entry.id.to_s)
          expect(data['data']['attributes']['fields']['title']).to eq('Test Article Title')
        end
      end

      response '404', 'not found' do
        let(:id) { 'non-existent-id' }

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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']['type']).to eq('resource_not_found')
        end
      end
    end
  end
end
