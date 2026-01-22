# typed: false
# frozen_string_literal: true

# サンプルテナントのコンテンツタイプ作成
# - article (記事)
# - announcement (お知らせ)
# - video (動画)
# - terms (利用規約) - シングルトン
# - privacy (プライバシーポリシー) - シングルトン

# =============================================================================
# ヘルパーメソッド
# =============================================================================

def create_content_type(unique_name:, display_name:, description:, is_collection:, fields:)
  content_type = ContentType.find_or_initialize_by(
    tenant_id: TENANT_ID,
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
      tenant_id: TENANT_ID,
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
    end

    ContentType::Field.create!(
      content_type: content_type,
      tenant_id: TENANT_ID,
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
# コンテンツタイプ作成
# =============================================================================

# 記事 (article)
ARTICLE_TYPE = create_content_type(
  unique_name: 'article',
  display_name: '記事',
  description: 'ブログ記事やニュースなどのコンテンツ',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: '記事のタイトル' },
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '記事の本文（リッチテキスト）' },
    { api_identifier: 'file', label: 'ファイル', field_type: :media_asset, required: false, description: '添付ファイル' },
  ],
)

# お知らせ (announcement)
ANNOUNCEMENT_TYPE = create_content_type(
  unique_name: 'announcement',
  display_name: 'お知らせ',
  description: '重要なお知らせや通知',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: 'お知らせのタイトル' },
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: false, description: 'お知らせの本文' },
  ],
)

# 動画 (video)
VIDEO_TYPE = create_content_type(
  unique_name: 'video',
  display_name: '動画',
  description: '動画コンテンツ',
  is_collection: true,
  fields: [
    { api_identifier: 'title', label: 'タイトル', field_type: :text, required: true, description: '動画のタイトル' },
    { api_identifier: 'video_file', label: '動画ファイル', field_type: :media_asset, required: true, description: '動画ファイル' },
  ],
)

# 利用規約 (terms) - シングルトン
TERMS_TYPE = create_content_type(
  unique_name: 'terms',
  display_name: '利用規約',
  description: 'サービス利用規約',
  is_collection: false,
  fields: [
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: '利用規約の本文' },
  ],
)

# プライバシーポリシー (privacy) - シングルトン
PRIVACY_TYPE = create_content_type(
  unique_name: 'privacy',
  display_name: 'プライバシーポリシー',
  description: '個人情報保護方針',
  is_collection: false,
  fields: [
    { api_identifier: 'body', label: '本文', field_type: :richtext, required: true, description: 'プライバシーポリシーの本文' },
  ],
)
