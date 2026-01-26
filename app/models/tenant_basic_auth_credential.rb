# typed: strict
# frozen_string_literal: true

class TenantBasicAuthCredential < ApplicationRecord
  extend T::Sig

  has_secure_password

  belongs_to :tenant_basic_auth

  validates :username, presence: true
  validates :username, uniqueness: { scope: :tenant_basic_auth_id }
  validates :password, presence: true, on: :create

  sig { params(input_password: String).returns(T::Boolean) }
  def valid_password?(input_password)
    !!authenticate(input_password)
  end
end
