# typed: false
# frozen_string_literal: true

# Set current tenant for default_scope
Tenant.current_id = 'dev-tenant'

# Collection types
ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000001' # article
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000002' # announcement
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000003' # video
  t.tenant_id = 'dev-tenant'
  t.is_collection = true
end

# Singleton types
ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000010' # terms
  t.tenant_id = 'dev-tenant'
  t.is_collection = false
end

ContentType.seed(:id) do |t|
  t.id = '00000000-0000-0000-0000-000000000011' # privacy
  t.tenant_id = 'dev-tenant'
  t.is_collection = false
end
