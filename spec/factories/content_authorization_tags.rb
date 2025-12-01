# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_authorization_tag do
    tenant_id { Tenant.current_id }
    sequence(:name) { |n| "Tag #{n}" }
    remote_id { nil }
  end
end
