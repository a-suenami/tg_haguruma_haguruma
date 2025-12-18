# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_types
#
#  id            :uuid             not null, primary key
#  description   :text
#  display_name  :text
#  is_collection :boolean          default(TRUE), not null
#  unique_name   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :citext           not null
#
# Indexes
#
#  index_content_types_on_id_and_tenant_id  (id,tenant_id) UNIQUE
#  index_content_types_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
FactoryBot.define do
  factory :content_type do
    tenant
    sequence(:unique_name) { |n| "content-type-#{n}" }
    sequence(:display_name) { |n| "Content Type #{n}" }
    is_collection { true }
  end
end
