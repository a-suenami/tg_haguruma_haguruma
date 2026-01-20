# typed: false
# frozen_string_literal: true

# サンプルテナントのサイト設定

unless TenantSiteSettings.exists?(tenant_id: TENANT_ID)
  TenantSiteSettings.create!(
    tenant_id: TENANT_ID,
    features: {
      'news' => { 'enabled' => true },
      'ticket' => { 'enabled' => true },
      'blog' => { 'enabled' => true },
      'schedule' => { 'enabled' => true },
      'biography' => { 'enabled' => true },
    },
    landing: {
      'sections_order' => %w[auth news blog],
    },
  )
  puts "  Created site_settings for tenant: #{TENANT_ID}"
end
