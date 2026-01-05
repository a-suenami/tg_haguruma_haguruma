# typed: false
# frozen_string_literal: true

require 'yaml'
require_relative '../../tenant_domain_helper'

tenant_id = TenantDomainHelper.tenant_id_for('yokikotokiku')

def upload_yokikotokiku_logo(tenant_id)
  logo_path = File.join(__dir__, 'logo.svg')
  return nil unless File.exist?(logo_path)

  s3_client = MediaAsset::S3Client.new
  s3_object_path = "#{tenant_id}/logo/logo.svg"

  s3_client.upload(
    key: s3_object_path,
    body: File.read(logo_path),
    content_type: 'image/svg+xml',
  )

  MediaAsset.create!(
    tenant_id: tenant_id,
    mime_type: 'image/svg+xml',
    media_type: :image,
    file_size_bytes: File.size(logo_path),
    s3_object_path: s3_object_path,
    metadata: { original_filename: 'logo.svg' },
  )
end

theme = TenantTheme.find_by(tenant_id: tenant_id)

if theme
  # 既存のテーマがある場合、ロゴがなければ追加
  if theme.logo_media_asset_id.nil?
    logo_asset = upload_yokikotokiku_logo(tenant_id)
    theme.update!(logo_media_asset_id: logo_asset.id) if logo_asset
    puts "  Added logo for tenant: #{tenant_id}"
  else
    puts "  Theme: #{tenant_id} (already exists, skipping)"
  end
else
  # 新規作成（ロゴも同時に作成）
  logo_asset = upload_yokikotokiku_logo(tenant_id)
  theme_path = File.join(__dir__, 'theme.yml')

  config = if File.exist?(theme_path)
             YAML.load_file(theme_path).tap { |c| c.delete('tenant_id') }
           else
             {}
           end

  TenantTheme.create!(
    tenant_id: tenant_id,
    logo_media_asset_id: logo_asset&.id,
    **config.symbolize_keys,
  )
  puts "  Created theme with logo for tenant: #{tenant_id}"
end
