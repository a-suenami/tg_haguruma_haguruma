# typed: false
# frozen_string_literal: true

# テナントごとのロゴを db/fixtures/_shared/by_tenant/{tenant_id}/logo.* から読み込む
# ロゴファイルを S3 にアップロードし、TenantTheme.logo_media_asset_id に関連付ける
#
# 前提:
#   - 対象テナントが既に存在していること
#   - TenantTheme が既に作成されていること（10_tenant_themes.rb で作成される）
#   - S3/CloudFront の設定が完了していること

LOGO_EXTENSIONS = %w[logo.svg logo.png logo.jpg logo.jpeg].freeze

def mime_type_for(path)
  case File.extname(path).downcase
  when '.svg' then 'image/svg+xml'
  when '.png' then 'image/png'
  when '.jpg', '.jpeg' then 'image/jpeg'
  when '.gif' then 'image/gif'
  when '.webp' then 'image/webp'
  else 'application/octet-stream'
  end
end

Dir.glob(Rails.root.join('db/fixtures/_shared/by_tenant/*')).each do |tenant_dir|
  tenant_id = File.basename(tenant_dir)
  next unless Tenant.exists?(id: tenant_id)

  theme = TenantTheme.find_by(tenant_id: tenant_id)
  next unless theme

  # 既にロゴがあればスキップ
  if theme.logo_media_asset_id.present?
    puts "  - Logo already exists for tenant: #{tenant_id}"
    next
  end

  # ロゴファイルを探す
  logo_path = LOGO_EXTENSIONS.map { |f| File.join(tenant_dir, f) }.find { |p| File.exist?(p) }
  next unless logo_path

  Tenant.current_id = tenant_id

  # ファイルをアップロード
  uploaded_file = ActionDispatch::Http::UploadedFile.new(
    tempfile: File.open(logo_path),
    filename: File.basename(logo_path),
    type: mime_type_for(logo_path),
  )

  uploader = MediaAsset::Uploader.new
  result = uploader.upload(file: uploaded_file, tenant_id: tenant_id)

  theme.update!(logo_media_asset_id: result[:media_asset].id)
  puts "  ✓ Uploaded logo for tenant: #{tenant_id}"
rescue StandardError => e
  puts "  ✗ Failed to upload logo for tenant: #{tenant_id} - #{e.message}"
end
