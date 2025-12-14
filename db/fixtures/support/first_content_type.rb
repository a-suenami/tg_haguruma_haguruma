# typed: false
# frozen_string_literal: true

module Seeds
  module FirstContentType
    TENANT_ID = 'sample'
    ARTICLE_CONTENT_TYPE_ID = '10000000-0000-0000-0000-000000000001'

    FIELDS_CONFIG = [
      { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: '記事のタイトル' },
      { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '記事の本文（リッチテキスト）' },
      { api_identifier: 'file', label: 'ファイル', field_type: :media_asset, required: false, description: '添付ファイル' },
    ].freeze

    class << self
      def seed
        Tenant.current_id = TENANT_ID

        content_type = find_or_create_content_type
        seed_fields(content_type)
        content_type
      end

      private

      def find_or_create_content_type
        content_type = ContentType.find_or_initialize_by(
          id: ARTICLE_CONTENT_TYPE_ID,
          tenant_id: TENANT_ID,
        )

        if content_type.new_record?
          content_type.assign_attributes(
            is_collection: true,
            unique_name: 'article',
            display_name: '記事',
            description: 'サンプル記事コンテンツ',
          )
          content_type.save!
          puts "  ✓ Created content_type: article"
        else
          puts "  - content_type: article (already exists)"
        end

        content_type
      end

      def seed_fields(content_type)
        FIELDS_CONFIG.each_with_index do |config, index|
          create_field_if_not_exists(content_type, config.merge(position: index))
        end
      end

      def create_field_if_not_exists(content_type, config)
        existing = ContentType::Field.find_by(
          tenant_id: TENANT_ID,
          content_type_id: content_type.id,
          api_identifier: config[:api_identifier],
        )

        if existing
          puts "  - field: #{config[:api_identifier]} (already exists)"
          return existing
        end

        subtype_attrs = case config[:field_type]
        when :text
          { text: ContentType::FieldText.create! }
        when :richtext
          { richtext: ContentType::FieldRichtext.create! }
        when :media_asset
          { media_asset: ContentType::FieldMediaAsset.create! }
        end

        field = ContentType::Field.create!(
          content_type:,
          tenant_id: TENANT_ID,
          api_identifier: config[:api_identifier],
          label: config[:label],
          field_type: config[:field_type],
          description: config[:description] || '',
          required: config[:required] || false,
          position: config[:position],
          **subtype_attrs,
        )

        puts "  ✓ Created field: #{config[:api_identifier]}"
        field
      end
    end
  end
end
