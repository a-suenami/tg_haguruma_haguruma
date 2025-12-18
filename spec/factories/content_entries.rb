# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_entry do
    tenant_id { Tenant.current_id }
    content_type
  end
end
