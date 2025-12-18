# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_type_field, class: 'ContentType::Field' do
    tenant_id { Tenant.current_id }
    content_type
    sequence(:api_identifier) { |n| "field_#{n}" }
    label { 'Test Field' }
    field_type { :text }
    required { false }
    position { 0 }
    description { '' }
  end
end
