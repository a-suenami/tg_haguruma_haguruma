# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :user_tag do
    tenant_id { Tenant.current_id }
    user
    content_authorization_tag
  end
end
