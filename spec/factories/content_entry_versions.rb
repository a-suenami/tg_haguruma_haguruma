# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_entry_version, class: 'ContentEntry::Version' do
    tenant_id { Tenant.current_id }
    content_type
    content_entry
    version { 1 }
    status { :draft }
    is_public { false }
  end
end
