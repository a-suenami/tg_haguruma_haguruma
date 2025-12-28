# typed: false
# frozen_string_literal: true

# サンプルテナント作成

TENANT_ID = 'sample'

unless Tenant.exists?(id: TENANT_ID)
  Tenant.create!(
    id: TENANT_ID,
    name: 'サンプルテナント',
    user_page_domain: 'sample.localhost',
  )
  puts "  Created tenant: #{TENANT_ID}"
end

Tenant.current_id = TENANT_ID
