# typed: false
# frozen_string_literal: true

Tenant.seed(:id) do |t|
  t.id = 'dev-tenant'
  t.name = '開発用テナント'
  t.user_page_domain = 'dev-tenant.localhost'
end
