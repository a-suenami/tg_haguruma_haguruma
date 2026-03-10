# typed: false
# frozen_string_literal: true

require 'yaml'

def upload_placeholder_logo(tenant_id)
  placeholder_path = Rails.root.join('db/fixtures/_shared/test/placeholder_logo.svg')
  return nil unless File.exist?(placeholder_path)

  s3_client = MediaAsset::S3Client.new
  s3_object_path = "#{tenant_id}/logo/placeholder_logo.svg"

  s3_client.upload(
    key: s3_object_path,
    body: File.read(placeholder_path),
    content_type: 'image/svg+xml',
  )

  MediaAsset.create!(
    tenant_id: tenant_id,
    mime_type: 'image/svg+xml',
    media_type: :image,
    file_size_bytes: File.size(placeholder_path),
    s3_object_path: s3_object_path,
    metadata: { original_filename: 'placeholder_logo.svg' },
  )
end

theme_path = File.join(__dir__, 'theme.yml')
theme = TenantTheme.find_by(tenant_id: TENANT_ID)

if theme
  # 既存のテーマがある場合、ロゴがなければ追加
  if theme.logo_media_asset_id.nil?
    logo_asset = upload_placeholder_logo(TENANT_ID)
    theme.update!(logo_media_asset_id: logo_asset.id) if logo_asset
    puts "  Added placeholder logo for tenant: #{TENANT_ID}"
  end
else
  # 新規作成
  logo_asset = upload_placeholder_logo(TENANT_ID)

  config = if File.exist?(theme_path)
             YAML.load_file(theme_path).tap { |c| c.delete('tenant_id') }
           else
             {}
           end

  TenantTheme.create!(
    tenant_id: TENANT_ID,
    logo_media_asset_id: logo_asset&.id,
    **config.symbolize_keys,
  )
  puts "  Created theme with logo for tenant: #{TENANT_ID}"
end
