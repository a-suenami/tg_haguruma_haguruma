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
# Add more tenants here as needed
# -----------------------------------------------------------------------------
# example_tenant = Tenant.find_or_create_by!(
#   id: 'example',
#   name: 'Example Tenant'
# )
