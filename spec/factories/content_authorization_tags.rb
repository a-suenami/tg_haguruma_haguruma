# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_authorization_tags
#
#  id                                                :uuid             not null, primary key
#  name                                              :string           not null
#  created_at                                        :datetime         not null
#  updated_at                                        :datetime         not null
#  remote_id(External system ID for synchronization) :uuid
#  tenant_id                                         :citext           not null
#
# Indexes
#
#  index_content_authorization_tags_on_tenant_id_and_id         (tenant_id,id) UNIQUE
#  index_content_authorization_tags_on_tenant_id_and_name       (tenant_id,name) UNIQUE
#  index_content_authorization_tags_on_tenant_id_and_remote_id  (tenant_id,remote_id) UNIQUE WHERE (remote_id IS NOT NULL)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
FactoryBot.define do
  factory :content_authorization_tag do
    tenant_id { Tenant.current_id }
    sequence(:name) { |n| "Tag #{n}" }
    remote_id { nil }
  end
end
