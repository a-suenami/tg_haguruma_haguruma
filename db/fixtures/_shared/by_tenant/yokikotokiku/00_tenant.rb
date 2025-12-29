# typed: false
# frozen_string_literal: true

# 斧琴菊テナント作成（初期データ）
# 既に存在する場合はスキップ

tenant_id = 'yokikotokiku'

if Tenant.exists?(id: tenant_id)
  puts "  Tenant: #{tenant_id} (already exists, skipping)"
else
  Tenant.create!(
    id: tenant_id,
    name: '斧琴菊',
    user_page_domain: 'yokikotokiku.localhost',
  )
  puts "  Created tenant: #{tenant_id}"
end

Tenant.current_id = tenant_id
