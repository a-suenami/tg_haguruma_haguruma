# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのロゴ設定（初期データ）
# logo.svg を S3 にアップロードし、TenantTheme に設定

tenant_id = 'yokikotokiku'
logo_path = File.join(__dir__, 'logo.svg')

theme = TenantTheme.find_by(tenant_id: tenant_id)
return unless theme
return if theme.logo_media_asset_id.present?
return unless File.exist?(logo_path)

# ロゴファイルを S3 にアップロード
s3_client = MediaAsset::S3Client.new
s3_object_path = "#{tenant_id}/logo/logo.svg"

s3_client.upload(
  key: s3_object_path,
  body: File.read(logo_path),
  content_type: 'image/svg+xml',
)

# MediaAsset を作成
logo_asset = MediaAsset.create!(
  tenant_id: tenant_id,
  mime_type: 'image/svg+xml',
  media_type: :image,
  file_size_bytes: File.size(logo_path),
  s3_object_path: s3_object_path,
  metadata: { original_filename: 'logo.svg' },
)

# TenantTheme に設定
theme.update!(logo_media_asset_id: logo_asset.id)
puts "  Created logo for tenant: #{tenant_id}"
