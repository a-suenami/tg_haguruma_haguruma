# typed: false
# frozen_string_literal: true

# Set current tenant for default_scope
Tenant.current_id = 'dev-tenant'

# Helper to create field with proper unique check
def create_field_if_not_exists(tenant_id, content_type_id, api_identifier, label, field_type_symbol, description: nil, required: false)
  existing = ContentType::Field.find_by(
    tenant_id: tenant_id,
    content_type_id: content_type_id,
    api_identifier: api_identifier
  )
  return if existing

  content_type = ContentType.find(content_type_id)

  case field_type_symbol
  when :text
    subtype = ContentType::FieldText.create!
    ContentType::Field.create!(
      content_type: content_type,
      tenant_id: tenant_id,
      api_identifier: api_identifier,
      label: label,
      field_type: :text,
      text_id: subtype.id,
      description: description,
      required: required
    )
  when :richtext
    subtype = ContentType::FieldRichtext.create!
    ContentType::Field.create!(
      content_type: content_type,
      tenant_id: tenant_id,
      api_identifier: api_identifier,
      label: label,
      field_type: :richtext,
      richtext_id: subtype.id,
      description: description,
      required: required
    )
  when :media_asset
    subtype = ContentType::FieldMediaAsset.create!
    ContentType::Field.create!(
      content_type: content_type,
      tenant_id: tenant_id,
      api_identifier: api_identifier,
      label: label,
      field_type: :media_asset,
      media_asset_id: subtype.id,
      description: description,
      required: required
    )
  end
end

# 記事（article）のフィールド
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000001', 'title', 'タイトル', :text,
                           description: '記事のタイトル', required: true)
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000001', 'body', '本文', :richtext,
                           description: '記事の本文', required: true)

# お知らせ（announcement）のフィールド
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000002', 'title', 'タイトル', :text,
                           description: 'お知らせのタイトル', required: true)
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000002', 'body', '本文', :richtext,
                           description: 'お知らせの本文', required: false)

# 動画（video）のフィールド
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000003', 'title', 'タイトル', :text,
                           description: '動画のタイトル', required: true)
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000003', 'video_file', '動画ファイル', :media_asset,
                           description: '動画ファイル', required: true)

# 利用規約（terms）のフィールド
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000010', 'body', '本文', :richtext,
                           description: '利用規約の本文', required: true)

# プライバシーポリシー（privacy）のフィールド
create_field_if_not_exists('dev-tenant', '00000000-0000-0000-0000-000000000011', 'body', '本文', :richtext,
                           description: 'プライバシーポリシーの本文', required: true)
