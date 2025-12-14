# typed: false
# frozen_string_literal: true

module Seeds
  # Seed helper for sample data (development/staging)
  # Uses service classes where possible for dogfooding
  class SampleDataSeeder
    TENANT_ID = 'sample'
    ARTICLE_CONTENT_TYPE_ID = '10000000-0000-0000-0000-000000000001'

    class << self
      def seed_all
        seed_tenant
        seed_article_content_type
        seed_article_entries
      end

      # Tenant creation (idempotent)
      def seed_tenant
        return if Tenant.exists?(id: TENANT_ID)

        Tenant.create!(
          id: TENANT_ID,
          name: 'サンプルテナント',
          user_page_domain: 'sample.localhost',
        )
        puts "  ✓ Created tenant: #{TENANT_ID}"
      end

      # ContentType creation (idempotent)
      # No service class exists, so we use AR directly with find_or_create pattern
      def seed_article_content_type
        Tenant.current_id = TENANT_ID

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

        seed_article_fields(content_type)
        content_type
      end

      # ContentType::Field creation (idempotent)
      def seed_article_fields(content_type)
        fields_config = [
          { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: '記事のタイトル' },
          { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '記事の本文（リッチテキスト）' },
          { api_identifier: 'file', label: 'ファイル', field_type: :media_asset, required: false, description: '添付ファイル' },
        ]

        fields_config.each_with_index do |config, index|
          create_field_if_not_exists(content_type, config.merge(position: index))
        end
      end

      # ContentEntry creation using SaveEntryService (idempotent via unique title check)
      def seed_article_entries
        Tenant.current_id = TENANT_ID

        content_type = ContentType.find(ARTICLE_CONTENT_TYPE_ID)

        articles_data.each do |article|
          create_article_entry(content_type, article)
        end
      end

      private

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

        # Create subtype record based on field_type
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

      def create_article_entry(content_type, article_data)
        # Check if article with same title already exists (for idempotency)
        existing_entry = find_entry_by_title(content_type, article_data[:title])
        if existing_entry
          puts "  - article: #{article_data[:title]} (already exists)"
          return existing_entry
        end

        # Use SaveEntryService to create entry (dogfooding)
        result = AdminArea::Contents::SaveEntryService.new(
          content_type:,
          content_entry: nil,
          fields_params: {
            'title' => article_data[:title],
            'body' => article_data[:body],
            # 'file' is left empty - actual files should be uploaded via UI
          },
        ).call

        unless result.success
          puts "  ✗ Failed to create article: #{article_data[:title]} - #{result.errors.join(', ')}"
          return nil
        end

        # Publish if requested
        if article_data[:publish]
          publish_result = AdminArea::Contents::PublishEntryService.new(
            content_type:,
            content_entry: result.content_entry,
          ).call

          unless publish_result.success
            puts "  ✗ Failed to publish article: #{article_data[:title]} - #{publish_result.errors.join(', ')}"
          end
        end

        status = article_data[:publish] ? '公開済み' : '下書き'
        puts "  ✓ Created article: #{article_data[:title]} (#{status})"
        result.content_entry
      end

      def find_entry_by_title(content_type, title)
        # Find entry by matching title field value
        content_type.content_entries.find do |entry|
          title_field = entry.fields.joins(:text).find_by(
            content_type_field: content_type.fields.find_by(api_identifier: 'title'),
          )
          title_field&.text&.value == title
        end
      end

      def articles_data
        [
          {
            title: 'はじめてのRuby on Rails',
            body: richtext_content('Ruby on Railsの基本的な使い方を解説します。MVCアーキテクチャの理解から始めましょう。'),
            publish: true,
          },
          {
            title: 'データベース設計のベストプラクティス',
            body: richtext_content('効率的なデータベース設計のポイントをまとめました。正規化と非正規化のバランスが重要です。'),
            publish: true,
          },
          {
            title: 'RESTful API設計入門',
            body: richtext_content('RESTful APIの設計原則と実装方法について解説します。リソース指向の考え方を身につけましょう。'),
            publish: true,
          },
          {
            title: 'テスト駆動開発（TDD）の実践',
            body: richtext_content('TDDの基本から実践的なテクニックまで解説します。Red-Green-Refactorのサイクルを回しましょう。'),
            publish: true,
          },
          {
            title: 'Dockerコンテナ入門',
            body: richtext_content('Dockerの基本概念と実践的な使い方を学びます。開発環境の統一化に役立ちます。'),
            publish: true,
          },
          {
            title: 'GitHubワークフロー完全ガイド',
            body: richtext_content('GitHubを使ったチーム開発のワークフローを解説します。プルリクエストとコードレビューの文化を作りましょう。'),
            publish: false,
          },
          {
            title: 'セキュリティ対策の基本',
            body: richtext_content('Webアプリケーションのセキュリティ対策について解説します。OWASP Top 10を理解しましょう。'),
            publish: false,
          },
          {
            title: 'パフォーマンスチューニング入門',
            body: richtext_content('アプリケーションのパフォーマンスを改善する方法を紹介します。ボトルネックの特定が第一歩です。'),
            publish: true,
          },
          {
            title: 'マイクロサービスアーキテクチャ',
            body: richtext_content('マイクロサービスの設計原則と実装パターンを学びます。モノリスからの移行も解説します。'),
            publish: false,
          },
          {
            title: 'CI/CDパイプラインの構築',
            body: richtext_content('継続的インテグレーションと継続的デリバリーの実践方法を解説します。自動化で開発効率を上げましょう。'),
            publish: true,
          },
        ]
      end

      def richtext_content(text)
        {
          'type' => 'doc',
          'content' => [
            {
              'type' => 'paragraph',
              'content' => [
                { 'type' => 'text', 'text' => text },
              ],
            },
          ],
        }
      end
    end
  end
end
