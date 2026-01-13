# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのキービジュアル（KV）コンテンツエントリ作成（初期データ）
# kv.svg を S3 にアップロードし、ContentEntry を作成

require_relative '../../tenant_domain_helper'

tenant_id = TenantDomainHelper.tenant_id_for('yokikotokiku')
kv_path = File.join(__dir__, 'kv.svg')

content_type = ContentType.find_by(tenant_id: tenant_id, unique_name: 'kv')
return unless content_type
return unless File.exist?(kv_path)

# 既にエントリが存在する場合はスキップ
if ContentEntry.exists?(tenant_id: tenant_id, content_type_id: content_type.id)
  puts "  KV entry: #{tenant_id} (already exists, skipping)"
  return
end

# KV画像を S3 にアップロード
s3_client = MediaAsset::S3Client.new
s3_object_path = "#{tenant_id}/content/kv/image.svg"

s3_client.upload(
  key: s3_object_path,
  body: File.read(kv_path),
  content_type: 'image/svg+xml',
)

# MediaAsset を作成
kv_asset = MediaAsset.create!(
  tenant_id: tenant_id,
  mime_type: 'image/svg+xml',
  media_type: :image,
  file_size_bytes: File.size(kv_path),
  s3_object_path: s3_object_path,
  metadata: { original_filename: 'kv.svg' },
)

# ContentEntry を作成
entry = ContentEntry.create!(
  tenant_id: tenant_id,
  content_type: content_type,
)

# ContentEntry::Version を作成（公開済み）
version = ContentEntry::Version.create!(
  tenant_id: tenant_id,
  content_type_id: content_type.id,
  content_entry_id: entry.id,
  version: 1,
  status: :published,
  visibility: :public,
  is_public: true,
  published_at: Time.current,
)

# ContentEntry::FieldMediaAsset を作成
field_media_asset = ContentEntry::FieldMediaAsset.create!(
  tenant_id: tenant_id,
  media_asset: kv_asset,
  media_type: :image,
)

# ContentEntry::Field を作成（画像フィールド）
image_field = content_type.fields.find_by(api_identifier: 'image')
ContentEntry::Field.create!(
  tenant_id: tenant_id,
  content_type_id: content_type.id,
  content_entry_id: entry.id,
  version: 1,
  content_type_field_id: image_field.id,
  field_type: :media_asset,
  media_asset: field_media_asset,
)

puts "  Created KV entry for tenant: #{tenant_id}"
