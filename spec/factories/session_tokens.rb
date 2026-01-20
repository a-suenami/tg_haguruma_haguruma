# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: session_tokens
#
#  id         :string           not null, primary key
#  expires_at :datetime         not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :string           not null
#  user_id    :uuid             not null
#
# Indexes
#
#  idx_session_tokens_expires_at    (expires_at)
#  idx_session_tokens_tenant_id     (tenant_id)
#  idx_session_tokens_updated_at    (updated_at)
#  idx_session_tokens_user_id       (user_id)
#  index_session_tokens_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :session_token do
    user
    tenant_id { user.tenant_id }
    sequence(:id) { |n| "session-token-#{n}" }
    expires_at { 1.day.from_now }

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
