# frozen_string_literal: true

# ==============================================================================
# Admins & Auth0 Accounts
# ==============================================================================

Rails.logger.debug '👤 Seeding Admins & Auth0 Accounts...'

# -----------------------------------------------------------------------------
# Ensure sample tenant exists
# -----------------------------------------------------------------------------
sample_tenant = Tenant.find_or_create_by!(id: 'sample') do |tenant|
  tenant.name = 'Sample Tenant'
end

Rails.logger.debug { "  ✅ Tenant: #{sample_tenant.name} (#{sample_tenant.id})" }

# -----------------------------------------------------------------------------
# Production Admin (Mrs. Tram) - Same Auth0 account as Ruler
# -----------------------------------------------------------------------------
ADMIN_AUTH0_UID = 'auth0|68f1fd7285c3c569694ab97e'
ADMIN_EMAIL = 'thi.tram@twogate.com'
ADMIN_NAME = 'Thi Tram'

# Find or create Auth0Account (may already exist from rulers seed)
auth0_account = Auth0Account.find_or_initialize_by(uid: ADMIN_AUTH0_UID)
auth0_account.email = ADMIN_EMAIL

if auth0_account.save
  Rails.logger.debug { "  ✅ Auth0Account: #{auth0_account.email}" }
else
  Rails.logger.debug { "  ❌ Failed: #{auth0_account.errors.full_messages.join(', ')}" }
  exit 1
end

# Create or update Admin for sample tenant
admin = Admin.find_or_initialize_by(tenant_id: sample_tenant.id, name: ADMIN_NAME)

if admin.save
  Rails.logger.debug { "  ✅ Admin: #{admin.name} (tenant: #{admin.tenant_id})" }
else
  Rails.logger.debug { "  ❌ Failed: #{admin.errors.full_messages.join(', ')}" }
  exit 1
end

# Link them via join table
Admin::Auth0Account.find_or_create_by!(
  tenant_id: sample_tenant.id,
  admin:,
  auth0_account:,
)

Rails.logger.debug '  ✅ Linked Admin ↔ Auth0Account'
