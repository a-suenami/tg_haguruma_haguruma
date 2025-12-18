# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_tags
#
#  id                           :uuid             not null, primary key
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  content_authorization_tag_id :uuid             not null
#  tenant_id                    :citext           not null
#  user_id                      :uuid             not null
#
# Indexes
#
#  index_user_tags_on_tag               (content_authorization_tag_id)
#  index_user_tags_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#  index_user_tags_unique               (tenant_id,user_id,content_authorization_tag_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...        (content_authorization_tag_id => content_authorization_tags.id)
#  fk_rails_...        (tenant_id => tenants.id)
#  fk_user_tags_users  ([tenant_id, user_id] => users[tenant_id, id])
#
FactoryBot.define do
  factory :user_tag do
    tenant_id { Tenant.current_id }
    user
    content_authorization_tag
  end
end
