# frozen_string_literal: true

# ==============================================================================
# Tenants
# ==============================================================================

Rails.logger.debug '🏢 Seeding Tenants...'

# -----------------------------------------------------------------------------
# Sample Tenant (for development/testing)
# -----------------------------------------------------------------------------
sample_tenant = Tenant.find_or_initialize_by(id: 'sample')
sample_tenant.assign_attributes(
  name: 'Sample Tenant',
  user_page_domain: nil,
)

if sample_tenant.save
  Rails.logger.debug { "  ✅ Tenant: #{sample_tenant.name} (#{sample_tenant.id})" }
else
  Rails.logger.debug { "  ❌ Failed: #{sample_tenant.errors.full_messages.join(', ')}" }
end

# -----------------------------------------------------------------------------
# Dev Tenant (for local development)
# -----------------------------------------------------------------------------
dev_tenant = Tenant.find_or_initialize_by(id: 'dev-tenant')
dev_tenant.assign_attributes(
  name: 'Dev Tenant',
  user_page_domain: 'dev-tenant.localhost',
)

if dev_tenant.save
  Rails.logger.debug { "  ✅ Tenant: #{dev_tenant.name} (#{dev_tenant.id})" }
else
  Rails.logger.debug { "  ❌ Failed: #{dev_tenant.errors.full_messages.join(', ')}" }
end
