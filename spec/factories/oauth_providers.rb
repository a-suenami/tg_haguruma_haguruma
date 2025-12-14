# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_providers
#
#  id                                                         :uuid             not null, primary key
#  client_secret                                              :string
#  endpoint_base                                              :string           not null
#  keypath_uid(UIDを取得するためのkeypath (デフォルト: sub))  :string
#  kind(user or admin)                                        :string           default("user"), not null
#  scopes                                                     :string           default(""), not null
#  session_expires_in(セッショントークンの有効期間 (90 days)) :integer          default(7776000), not null
#  created_at                                                 :datetime         not null
#  updated_at                                                 :datetime         not null
#  client_id                                                  :string           not null
#  tenant_id                                                  :string           not null
#
# Indexes
#
#  index_oauth_providers_on_tenant_id           (tenant_id)
#  index_oauth_providers_on_tenant_id_and_kind  (tenant_id,kind) UNIQUE WHERE ((kind)::text = 'user'::text)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
FactoryBot.define do
  factory :oauth_provider do
    tenant
    client_id { 'test-client-id' }
    client_secret { 'test-client-secret' }
    endpoint_base { 'https://example.com/oauth' }
    kind { 'user' }
  end
end
