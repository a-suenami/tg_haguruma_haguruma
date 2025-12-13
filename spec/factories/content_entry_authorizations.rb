# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_entry_authorization do
    tenant_id { Tenant.current_id }
    content_entry_id { content_entry_version.content_entry_id }
    version { content_entry_version.version }
    content_authorization_tag

    transient do
      content_entry_version { nil }
    end
  end
end
