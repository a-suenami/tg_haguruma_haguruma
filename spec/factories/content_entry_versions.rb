# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entry_versions
#
#  id               :bigint           not null, primary key
#  is_public        :boolean          default(FALSE), not null
#  published_at     :datetime
#  status           :integer          not null
#  unpublished_at   :datetime
#  version          :integer          default(1), not null
#  created_at       :datetime         not null
#  content_entry_id :uuid             not null
#  content_type_id  :uuid             not null
#  tenant_id        :citext           not null
#
# Indexes
#
#  index_content_entry_versions_on_entry_version              (content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_tenant_is_public           (tenant_id,is_public)
#  index_content_entry_versions_on_tenant_type_entry_version  (tenant_id,content_type_id,content_entry_id,version) UNIQUE
#
# Foreign Keys
#
#  fk_content_entry_versions_content_entries  ([tenant_id, content_type_id, content_entry_id] => content_entries[tenant_id, content_type_id, id])
#
FactoryBot.define do
  factory :content_entry_version, class: 'ContentEntry::Version' do
    tenant
    content_type { association :content_type, tenant: }
    content_entry { association :content_entry, tenant:, content_type: }
    version { 1 }
    status { :draft }
  end
end
