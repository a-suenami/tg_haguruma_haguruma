# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entry_versions
#
#  id                       :bigint           not null, primary key
#  is_public                :boolean          default(FALSE), not null
#  preview_token            :string
#  preview_token_expires_at :datetime
#  published_at             :datetime
#  scheduled_publish_at     :datetime
#  status                   :integer          not null
#  unpublished_at           :datetime
#  version                  :integer          default(1), not null
#  visibility               :integer          default("public"), not null
#  created_at               :datetime         not null
#  content_entry_id         :uuid             not null
#  content_type_id          :uuid             not null
#  scheduled_job_id         :string
#  tenant_id                :citext           not null
#
# Indexes
#
#  index_content_entry_versions_on_entry_version              (content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_preview_token              (preview_token) UNIQUE WHERE (preview_token IS NOT NULL)
#  index_content_entry_versions_on_scheduled_publish          (scheduled_publish_at) WHERE ((scheduled_publish_at IS NOT NULL) AND (status = 1))
#  index_content_entry_versions_on_tenant_is_public           (tenant_id,is_public)
#  index_content_entry_versions_on_tenant_type_entry_version  (tenant_id,content_type_id,content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_tenant_visibility          (tenant_id,visibility)
#  index_content_entry_versions_on_token_expires_at           (preview_token_expires_at) WHERE (preview_token IS NOT NULL)
#  index_content_entry_versions_unique_draft_per_entry        (content_entry_id) UNIQUE WHERE (status = 1)
#  index_content_entry_versions_unique_published_per_entry    (content_entry_id) UNIQUE WHERE (status = 3)
#
# Foreign Keys
#
#  fk_content_entry_versions_content_entries  ([tenant_id, content_type_id, content_entry_id] => content_entries[tenant_id, content_type_id, id])
#
FactoryBot.define do
  factory :content_entry_version, class: 'ContentEntry::Version' do
    transient do
      tenant { association :tenant }
      content_type { association :content_type, tenant: }
      content_entry { association :content_entry, tenant:, content_type: }
    end

    tenant_id { tenant.id }
    content_type_id { content_type.id }
    content_entry_id { content_entry.id }
    version { 1 }
    status { :draft }

    # DB check constraint requires custom_published_at for published/unpublished versions
    after(:build) do |version|
      if version.published? && version.custom_published_at.nil?
        version.custom_published_at = version.published_at || Time.current
      end
    end
  end
end
