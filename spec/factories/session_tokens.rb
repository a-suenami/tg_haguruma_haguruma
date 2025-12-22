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
