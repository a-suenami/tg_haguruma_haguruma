# typed: false
# frozen_string_literal: true

module Seeds
  module SampleContentEntries
    TENANT_ID = 'sample'
    ARTICLE_CONTENT_TYPE_ID = '10000000-0000-0000-0000-000000000001'

    ARTICLES_DATA = [
      { title: 'はじめてのRuby on Rails', body: 'Ruby on Railsの基本的な使い方を解説します。MVCアーキテクチャの理解から始めましょう。', publish: true },
      { title: 'データベース設計のベストプラクティス', body: '効率的なデータベース設計のポイントをまとめました。正規化と非正規化のバランスが重要です。', publish: true },
      { title: 'RESTful API設計入門', body: 'RESTful APIの設計原則と実装方法について解説します。リソース指向の考え方を身につけましょう。', publish: true },
      { title: 'テスト駆動開発（TDD）の実践', body: 'TDDの基本から実践的なテクニックまで解説します。Red-Green-Refactorのサイクルを回しましょう。', publish: true },
      { title: 'Dockerコンテナ入門', body: 'Dockerの基本概念と実践的な使い方を学びます。開発環境の統一化に役立ちます。', publish: true },
      { title: 'GitHubワークフロー完全ガイド', body: 'GitHubを使ったチーム開発のワークフローを解説します。プルリクエストとコードレビューの文化を作りましょう。', publish: false },
      { title: 'セキュリティ対策の基本', body: 'Webアプリケーションのセキュリティ対策について解説します。OWASP Top 10を理解しましょう。', publish: false },
      { title: 'パフォーマンスチューニング入門', body: 'アプリケーションのパフォーマンスを改善する方法を紹介します。ボトルネックの特定が第一歩です。', publish: true },
      { title: 'マイクロサービスアーキテクチャ', body: 'マイクロサービスの設計原則と実装パターンを学びます。モノリスからの移行も解説します。', publish: false },
      { title: 'CI/CDパイプラインの構築', body: '継続的インテグレーションと継続的デリバリーの実践方法を解説します。自動化で開発効率を上げましょう。', publish: true },
    ].freeze

    class << self
      def seed
        Tenant.current_id = TENANT_ID
        content_type = ContentType.find(ARTICLE_CONTENT_TYPE_ID)

        ARTICLES_DATA.each do |article|
          create_article_entry(content_type, article)
        end
      end

      private

      def create_article_entry(content_type, article_data)
        existing_entry = find_entry_by_title(content_type, article_data[:title])
        if existing_entry
          puts "  - article: #{article_data[:title]} (already exists)"
          return existing_entry
        end

        result = AdminArea::Contents::SaveEntryService.new(
          content_type:,
          content_entry: nil,
          fields_params: {
            'title' => article_data[:title],
            'body' => richtext_content(article_data[:body]),
          },
        ).call

        unless result.success
          puts "  ✗ Failed to create article: #{article_data[:title]} - #{result.errors.join(', ')}"
          return nil
        end

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
        content_type.content_entries.find do |entry|
          title_field = entry.fields.joins(:text).find_by(
            content_type_field: content_type.fields.find_by(api_identifier: 'title'),
          )
          title_field&.text&.value == title
        end
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
