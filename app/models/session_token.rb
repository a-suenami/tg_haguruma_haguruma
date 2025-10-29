# frozen_string_literal: true

class SessionToken < ApplicationRecord
  belongs_to :user

  scope :available, -> { where(arel_table[:expires_at].gt(Time.current)) }
  scope :expired, -> { where(arel_table[:expires_at].lteq(Time.current)) }
end
