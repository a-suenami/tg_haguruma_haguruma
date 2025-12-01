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
class SessionToken < ApplicationRecord
  belongs_to :user

  scope :available, -> { where(arel_table[:expires_at].gt(Time.current)) }
  scope :expired, -> { where(arel_table[:expires_at].lteq(Time.current)) }
end
