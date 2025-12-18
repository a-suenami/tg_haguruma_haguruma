# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :tenant do
    id { 'sample' }
    display_name { 'Sample Tenant' }
  end
end
