# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.yaml'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Haguruma API V1',
        version: 'v1',
        description: 'API documentation for Haguruma',
      },
      paths: {},
      servers: [
        {
          url: '{protocol}://{tenant}.{domain}',
          description: 'Multi-tenant API server (tenant identified by subdomain)',
          variables: {
            protocol: {
              default: 'https',
              enum: %w[https http],
              description: 'Protocol scheme',
            },
            tenant: {
              default: 'your-tenant-id',
              description: 'Tenant subdomain identifier',
            },
            domain: {
              default: 'example.com',
              description: 'Base domain',
            },
          },
        },
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
          },
        },
        schemas: {
          ContentType: {
            type: :object,
            properties: {
              unique_name: { type: :string, example: 'article' },
              display_name: { type: :string, example: '記事' },
              is_collection: { type: :boolean, example: true },
            },
            required: %w[unique_name display_name is_collection],
          },
          FieldMetadata: {
            type: :object,
            properties: {
              unique_name: { type: :string, example: 'title' },
              display_name: { type: :string, example: 'タイトル' },
            },
            required: %w[unique_name display_name],
          },
          TextAttribute: {
            type: :object,
            properties: {
              type: { type: :string, enum: ['text'] },
              field: { '$ref' => '#/components/schemas/FieldMetadata' },
              text: {
                type: :object,
                properties: {
                  value: { type: :string, nullable: true },
                },
              },
            },
            required: %w[type field text],
          },
          RichtextAttribute: {
            type: :object,
            properties: {
              type: { type: :string, enum: ['richtext'] },
              field: { '$ref' => '#/components/schemas/FieldMetadata' },
              richtext: {
                type: :object,
                properties: {
                  json_value: { type: :object, nullable: true, description: 'Lexical editor JSON format' },
                },
              },
            },
            required: %w[type field richtext],
          },
          MediaAssetAttribute: {
            type: :object,
            properties: {
              type: { type: :string, enum: ['media_asset'] },
              field: { '$ref' => '#/components/schemas/FieldMetadata' },
              media_asset: {
                type: :object,
                properties: {
                  media_type: { type: :string, example: 'image' },
                  s3_object_path: { type: :string, example: 'tenant/2025/01/01/uuid.jpg' },
                },
              },
            },
            required: %w[type field media_asset],
          },
          ContentEntry: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              content_type: { '$ref' => '#/components/schemas/ContentType' },
              attributes: {
                type: :object,
                additionalProperties: {
                  oneOf: [
                    { '$ref' => '#/components/schemas/TextAttribute' },
                    { '$ref' => '#/components/schemas/RichtextAttribute' },
                    { '$ref' => '#/components/schemas/MediaAssetAttribute' },
                  ],
                },
              },
              version: { type: :integer, example: 1 },
              published_at: { type: :string, format: 'date-time', nullable: true },
            },
            required: %w[id content_type attributes version],
          },
          ContentEntryResponse: {
            type: :object,
            properties: {
              data: { '$ref' => '#/components/schemas/ContentEntry' },
            },
            required: ['data'],
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
            },
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this parameter is used to override the format when running
  # rswag:specs:swaggerize. Set to :yaml for YAML output.
  config.openapi_format = :yaml
end
