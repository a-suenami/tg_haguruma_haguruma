# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entries
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  content_type_id :uuid             not null
#  tenant_id       :citext           not null
#
# Indexes
#
#  index_content_entries_on_tenant_id_and_content_type_id_and_id  (tenant_id,content_type_id,id) UNIQUE
#  index_content_entries_on_tenant_id_and_id                      (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  ([tenant_id, content_type_id] => content_types[tenant_id, id])
#
FactoryBot.define do
  factory :content_entry do
    tenant
    content_type { association :content_type, tenant: }
    publication_date { Time.current }

    trait :published do
      after(:create) do |content_entry|
        create(:content_entry_version,
               tenant: content_entry.tenant,
               content_type: content_entry.content_type,
               content_entry:,
               status: :published,
               published_at: Time.current,)
      end
    end
  end
end
