# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのコンテンツタイプ作成（初期データ）
# 既に存在する場合はスキップ

tenant_id = 'yokikotokiku'

# =============================================================================
# ヘルパーメソッド
# =============================================================================

def create_content_type_if_not_exists(tenant_id, unique_name:, display_name:, description:, is_collection:, fields:)
  if ContentType.exists?(tenant_id: tenant_id, unique_name: unique_name)
    puts "  ContentType: #{unique_name} (already exists, skipping)"
    return nil
  end

  content_type = ContentType.create!(
    tenant_id: tenant_id,
    unique_name: unique_name,
    is_collection: is_collection,
    display_name: display_name,
    description: description,
  )
  puts "  Created ContentType: #{unique_name}"

  # フィールド作成
  fields.each_with_index do |config, index|
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
# コンテンツタイプ作成
# =============================================================================

# キービジュアル (kv) - シングルトン
create_content_type_if_not_exists(
  tenant_id,
  unique_name: 'kv',
  display_name: 'キービジュアル',
  description: 'トップページのキービジュアル',
  is_collection: false,
  fields: [
    { api_identifier: 'image', label: '画像', field_type: :media_asset, required: true, description: 'キービジュアル画像' },
  ],
)

# =============================================================================
# TODO: 以下のコンテンツタイプは後日追加
# =============================================================================
# - お知らせ (announcement)
# - お切符 (ticket)
# - メッセージ (message)
# - プロフィール (profile)
