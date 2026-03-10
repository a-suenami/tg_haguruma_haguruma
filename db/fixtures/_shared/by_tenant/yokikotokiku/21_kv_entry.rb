# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのキービジュアル（KV）コンテンツエントリ作成（初期データ）
# kv.svg を S3 にアップロードし、ContentEntry を作成（PC/SP両方）

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

s3_client = MediaAsset::S3Client.new

# PC用KV画像を S3 にアップロード
s3_object_path_pc = "#{tenant_id}/content/kv/image_pc.svg"
s3_client.upload(
  key: s3_object_path_pc,
  body: File.read(kv_path),
  content_type: 'image/svg+xml',
)

# SP用KV画像を S3 にアップロード（同じファイルを使用）
s3_object_path_sp = "#{tenant_id}/content/kv/image_sp.svg"
s3_client.upload(
  key: s3_object_path_sp,
  body: File.read(kv_path),
  content_type: 'image/svg+xml',
)

# PC用 MediaAsset を作成
kv_asset_pc = MediaAsset.create!(
  tenant_id: tenant_id,
  mime_type: 'image/svg+xml',
  media_type: :image,
  file_size_bytes: File.size(kv_path),
  s3_object_path: s3_object_path_pc,
  metadata: { original_filename: 'kv_pc.svg' },
)

# SP用 MediaAsset を作成
kv_asset_sp = MediaAsset.create!(
  tenant_id: tenant_id,
  mime_type: 'image/svg+xml',
  media_type: :image,
  file_size_bytes: File.size(kv_path),
  s3_object_path: s3_object_path_sp,
  metadata: { original_filename: 'kv_sp.svg' },
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

# PC用 ContentEntry::FieldMediaAsset を作成
field_media_asset_pc = ContentEntry::FieldMediaAsset.create!(
  tenant_id: tenant_id,
  media_asset: kv_asset_pc,
  media_type: :image,
)

# SP用 ContentEntry::FieldMediaAsset を作成
field_media_asset_sp = ContentEntry::FieldMediaAsset.create!(
  tenant_id: tenant_id,
  media_asset: kv_asset_sp,
  media_type: :image,
)

# PC用 ContentEntry::Field を作成
image_pc_field = content_type.fields.find_by(api_identifier: 'image_pc')
ContentEntry::Field.create!(
  tenant_id: tenant_id,
  content_type_id: content_type.id,
  content_entry_id: entry.id,
  version: 1,
  content_type_field_id: image_pc_field.id,
  field_type: :media_asset,
  media_asset: field_media_asset_pc,
)

# SP用 ContentEntry::Field を作成
image_sp_field = content_type.fields.find_by(api_identifier: 'image_sp')
ContentEntry::Field.create!(
  tenant_id: tenant_id,
  content_type_id: content_type.id,
  content_entry_id: entry.id,
  version: 1,
  content_type_field_id: image_sp_field.id,
  field_type: :media_asset,
  media_asset: field_media_asset_sp,
)

puts "  Created KV entry for tenant: #{tenant_id}"
