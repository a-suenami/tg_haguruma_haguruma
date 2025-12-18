# typed: false
# frozen_string_literal: true

FactoryBot.define do
  factory :content_entry_field, class: 'ContentEntry::Field' do
    tenant_id { Tenant.current_id }
    content_type_id { content_type_field.content_type_id }
    content_entry_id { content_entry_version.content_entry_id }
    version { content_entry_version.version }
    content_type_field
    field_type { content_type_field.field_type }

    transient do
      content_entry_version { nil }
    end
  end

  factory :content_entry_field_text, class: 'ContentEntry::FieldText' do
    value { 'Test value' }
  end

  factory :content_entry_field_richtext, class: 'ContentEntry::FieldRichtext' do
    value { { 'html' => '<p>Test content</p>' } }
  end
end
