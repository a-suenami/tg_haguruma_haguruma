# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                        :uuid             not null, primary key
#  last_authenticated_at     :datetime
#  uid(IDP platform user ID) :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  oauth_provider_id         :uuid             not null
#  tenant_id                 :citext           not null
#
# Indexes
#
#  index_users_on_oauth_provider_id  (oauth_provider_id)
#  index_users_on_tenant_id_and_id   (tenant_id,id) UNIQUE
#  index_users_on_tenant_id_and_uid  (tenant_id,uid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (oauth_provider_id => oauth_providers.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
FactoryBot.define do
  factory :user do
    tenant
    oauth_provider { association :oauth_provider, tenant: }
    sequence(:uid) { |n| "user-uid-#{n}" }
  end
end
