# typed: false
# frozen_string_literal: true

# サンプルテナントのエントリ作成
# - 記事 10件
# - お知らせ 3件
# - 利用規約 1件 (シングルトン)
# - プライバシーポリシー 1件 (シングルトン)

# =============================================================================
# ヘルパーメソッド
# =============================================================================

def richtext_content(text)
  {
    'root' => {
      'type' => 'root',
      'version' => 1,
      'direction' => 'ltr',
      'format' => '',
      'indent' => 0,
      'children' => [
        {
          'type' => 'paragraph',
          'version' => 1,
          'direction' => 'ltr',
          'format' => '',
          'indent' => 0,
          'children' => [
            { 'type' => 'text', 'version' => 1, 'text' => text, 'format' => 0, 'mode' => 'normal', 'style' => '' },
          ],
        },
      ],
    },
  }
end

def find_entry_by_title(content_type, title)
  title_field_def = content_type.fields.find_by(api_identifier: 'title')
  return nil unless title_field_def

  content_type.content_entries.find do |entry|
    version = entry.versions.first
    next unless version

    title_field = version.fields.joins(:text).find_by(content_type_field: title_field_def)
    title_field&.text&.value == title
  end
end

def create_entry(content_type:, fields_params:, publish: false)
  result = AdminArea::Contents::SaveEntryService.new(
    content_type: content_type,
    content_entry: nil,
    fields_params: fields_params,
  ).call

  return nil unless result.success

  if publish
    AdminArea::Contents::PublishEntryService.new(
      content_type: content_type,
      content_entry: result.content_entry,
    ).call
  end

  result.content_entry
end

# =============================================================================
# 記事エントリ
# =============================================================================

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

ARTICLES_DATA.each do |data|
  if find_entry_by_title(ARTICLE_TYPE, data[:title])
    puts "  article: #{data[:title]} (already exists)"
    next
  end

  entry = create_entry(
    content_type: ARTICLE_TYPE,
    fields_params: { 'title' => data[:title], 'body' => richtext_content(data[:body]) },
    publish: data[:publish],
  )

  if entry
    status = data[:publish] ? '公開済み' : '下書き'
    puts "  Created article: #{data[:title]} (#{status})"
  else
    puts "  Failed to create article: #{data[:title]}"
  end
end

# =============================================================================
# お知らせエントリ
# =============================================================================

ANNOUNCEMENTS_DATA = [
  { title: 'システムメンテナンスのお知らせ', body: '2025年1月15日（水）午前2時から4時までシステムメンテナンスを実施します。', publish: true },
  { title: '新機能リリースのご案内', body: '新しい機能がリリースされました。詳細はこちらをご覧ください。', publish: true },
  { title: 'セキュリティアップデートの実施', body: 'セキュリティ向上のためのアップデートを実施しました。', publish: true },
].freeze

ANNOUNCEMENTS_DATA.each do |data|
  if find_entry_by_title(ANNOUNCEMENT_TYPE, data[:title])
    puts "  announcement: #{data[:title]} (already exists)"
    next
  end

  entry = create_entry(
    content_type: ANNOUNCEMENT_TYPE,
    fields_params: { 'title' => data[:title], 'body' => richtext_content(data[:body]) },
    publish: data[:publish],
  )

  if entry
    puts "  Created announcement: #{data[:title]}"
  else
    puts "  Failed to create announcement: #{data[:title]}"
  end
end

# =============================================================================
# 利用規約エントリ (シングルトン)
# =============================================================================

if TERMS_TYPE.content_entries.empty?
  terms_body = {
    'root' => {
      'type' => 'root',
      'version' => 1,
      'direction' => 'ltr',
      'format' => '',
      'indent' => 0,
      'children' => [
        { 'type' => 'heading', 'version' => 1, 'tag' => 'h1', 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '利用規約', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'paragraph', 'version' => 1, 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '本利用規約は、当サービスの利用条件を定めるものです。', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'heading', 'version' => 1, 'tag' => 'h2', 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '第1条（適用）', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'paragraph', 'version' => 1, 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '本規約は、本サービスの提供条件及び本サービスの利用に関する当社とユーザーとの間の権利義務関係を定めることを目的とし、ユーザーと当社との間の本サービスの利用に関わる一切の関係に適用されます。', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
      ],
    },
  }

  entry = create_entry(content_type: TERMS_TYPE, fields_params: { 'body' => terms_body }, publish: true)
  puts entry ? '  Created terms (singleton)' : '  Failed to create terms'
else
  puts '  terms (already exists)'
end

# =============================================================================
# プライバシーポリシーエントリ (シングルトン)
# =============================================================================

if PRIVACY_TYPE.content_entries.empty?
  privacy_body = {
    'root' => {
      'type' => 'root',
      'version' => 1,
      'direction' => 'ltr',
      'format' => '',
      'indent' => 0,
      'children' => [
        { 'type' => 'heading', 'version' => 1, 'tag' => 'h1', 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => 'プライバシーポリシー', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'paragraph', 'version' => 1, 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '当社は、ユーザーの個人情報保護の重要性について認識し、個人情報の保護に関する法律を遵守すると共に、以下のプライバシーポリシーに従って、個人情報を適切に取り扱います。', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'heading', 'version' => 1, 'tag' => 'h2', 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '1. 個人情報の収集', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
        { 'type' => 'paragraph', 'version' => 1, 'direction' => 'ltr', 'format' => '', 'indent' => 0, 'children' => [{ 'type' => 'text', 'version' => 1, 'text' => '当社は、サービス提供のために必要な範囲で個人情報を収集します。', 'format' => 0, 'mode' => 'normal', 'style' => '' }] },
      ],
    },
  }

  entry = create_entry(content_type: PRIVACY_TYPE, fields_params: { 'body' => privacy_body }, publish: true)
  puts entry ? '  Created privacy (singleton)' : '  Failed to create privacy'
else
  puts '  privacy (already exists)'
end
