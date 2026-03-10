# typed: false
# frozen_string_literal: true

# 斧琴菊テナントのサイト設定（初期データ）
# 既に存在する場合はスキップ

require_relative '../../tenant_domain_helper'

tenant_id = TenantDomainHelper.tenant_id_for('yokikotokiku')

if TenantSiteSettings.exists?(tenant_id: tenant_id)
  puts "  SiteSettings: #{tenant_id} (already exists, skipping)"
else
  TenantSiteSettings.create!(
    tenant_id: tenant_id,
    features: {
      'news' => { 'enabled' => true, 'label' => 'お知らせ', 'menu_label' => 'お知らせ' },
      'ticket' => { 'enabled' => true, 'label' => 'お切符', 'menu_label' => 'お切符' },
      'blog' => { 'enabled' => true, 'label' => 'メッセージ', 'menu_label' => 'メッセージ' },
      'biography' => { 'enabled' => true, 'label' => 'プロフィール', 'menu_label' => 'プロフィール' },
    },
    landing: {},
  )
  puts "  Created site_settings for tenant: #{tenant_id}"
end
