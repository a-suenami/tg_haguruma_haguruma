# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのフィーチャー用コンテンツタイプ作成
# - news (お知らせ)
# - blog (メッセージ)
# - ticket (お切符)
# - biography (プロフィール)

require_relative '../../tenant_domain_helper'

tenant_id = TenantDomainHelper.tenant_id_for('yokikotokiku')

# =============================================================================
# ヘルパーメソッド
# =============================================================================

def create_content_type_with_select_fields(tenant_id, unique_name:, display_name:, description:, is_collection:, fields:)
  content_type = ContentType.find_or_initialize_by(
    tenant_id: tenant_id,
    unique_name: unique_name,
  )

  if content_type.new_record?
    content_type.assign_attributes(
      is_collection: is_collection,
      display_name: display_name,
      description: description,
    )
    content_type.save!
    puts "  Created content_type: #{unique_name}"
  else
    puts "  content_type: #{unique_name} (already exists)"
  end

  # フィールド作成
  fields.each_with_index do |config, index|
    existing = ContentType::Field.find_by(
      tenant_id: tenant_id,
      content_type_id: content_type.id,
      api_identifier: config[:api_identifier],
    )

    if existing
      puts "    field: #{config[:api_identifier]} (already exists)"
      next
    end

    subtype_attrs = case config[:field_type]
    when :text
      { text: ContentType::FieldText.create! }
    when :richtext
      { richtext: ContentType::FieldRichtext.create! }
    when :media_asset
      { media_asset: ContentType::FieldMediaAsset.create! }
    when :select_field
      field_select = ContentType::FieldSelect.create!(
        display_format: config[:display_format] || :dropdown,
      )
      # 選択肢を作成
      (config[:options] || []).each_with_index do |option, opt_index|
        ContentType::FieldSelectOption.create!(
          field_select: field_select,
          unique_name: option[:unique_name],
          display_name: option[:display_name],
          position: opt_index,
        )
      end
      { select: field_select }
    end

    ContentType::Field.create!(
      content_type: content_type,
      tenant_id: tenant_id,
      api_identifier: config[:api_identifier],
      label: config[:label],
      field_type: config[:field_type],
      description: config[:description] || '',
      required: config[:required] || false,
      position: index,
      **subtype_attrs,
    )

    puts "    Created field: #{config[:api_identifier]}"
  end

  content_type
end

# =============================================================================
# カテゴリオプション定義
# =============================================================================

NEWS_CATEGORIES = [
  { unique_name: 'update_history', display_name: '更新履歴' },
  { unique_name: 'news', display_name: 'ニュース' },
  { unique_name: 'mail', display_name: 'メール' },
  { unique_name: 'shipping', display_name: '発送物' },
  { unique_name: 'viewing_gift', display_name: '観覧・プレゼント' },
  { unique_name: 'special', display_name: 'スペシャル' },
  { unique_name: 'overseas', display_name: '海外番組記' },
].freeze

BLOG_CATEGORIES = [
  { unique_name: 'personal', display_name: '本人ブログ' },
  { unique_name: 'movie', display_name: 'ムービー' },
  { unique_name: 'staff', display_name: 'スタッフ' },
].freeze

TICKET_CATEGORIES = [
  { unique_name: 'performance', display_name: '公演' },
  { unique_name: 'tea_party', display_name: 'お茶会' },
  { unique_name: 'other', display_name: 'その他' },
].freeze

# =============================================================================
# コンテンツタイプ作成
# =============================================================================

# お知らせ (news)
create_content_type_with_select_fields(
  tenant_id,
  unique_name: 'news',
  display_name: 'お知らせ',
  description: 'お知らせ',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: 'タイトル' },
    { api_identifier: 'category', label: 'カテゴリ', field_type: :select_field, required: false, description: 'カテゴリ', display_format: :dropdown, options: NEWS_CATEGORIES },
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '本文（リッチテキスト）' },
    { api_identifier: 'thumbnail', label: 'サムネイル', field_type: :media_asset, required: false, description: 'サムネイル画像' },
  ],
)

# メッセージ (blog)
create_content_type_with_select_fields(
  tenant_id,
  unique_name: 'blog',
  display_name: 'メッセージ',
  description: 'メッセージ',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: 'タイトル' },
    { api_identifier: 'category', label: 'カテゴリ', field_type: :select_field, required: false, description: 'カテゴリ', display_format: :dropdown, options: BLOG_CATEGORIES },
    { api_identifier: 'thumbnail', label: 'サムネイル', field_type: :media_asset, required: false, description: 'サムネイル画像' },
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '本文（リッチテキスト）' },
  ],
)

# お切符 (ticket)
create_content_type_with_select_fields(
  tenant_id,
  unique_name: 'ticket',
  display_name: 'お切符',
  description: 'お切符情報',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: 'タイトル' },
    { api_identifier: 'category', label: 'カテゴリ', field_type: :select_field, required: false, description: 'カテゴリ', display_format: :dropdown, options: TICKET_CATEGORIES },
    { api_identifier: 'thumbnail', label: 'サムネイル', field_type: :media_asset, required: false, description: 'サムネイル画像' },
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '本文（リッチテキスト）' },
  ],
)

# プロフィール (biography) - シングルトン
create_content_type_with_select_fields(
  tenant_id,
  unique_name: 'biography',
  display_name: 'プロフィール',
  description: 'プロフィール',
  is_collection: false,
  fields: [
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '本文（リッチテキスト）' },
  ],
)
