# typed: false
# frozen_string_literal: true

# サンプルテナント作成

require_relative '../../tenant_domain_helper'

TENANT_ID = TenantDomainHelper.tenant_id_for('sample')

unless Tenant.exists?(id: TENANT_ID)
  Tenant.create!(
    id: TENANT_ID,
    name: 'サンプルテナント',
    user_page_domain: TenantDomainHelper.user_page_domain_for(TENANT_ID),
  )
  puts "  Created tenant: #{TENANT_ID}"
end

Tenant.current_id = TENANT_ID
