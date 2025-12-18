# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_type do
    tenant_id { Tenant.current_id }
    sequence(:unique_name) { |n| "content_type_#{n}" }
    display_name { 'Test Content Type' }
    is_collection { true }
  end
end
