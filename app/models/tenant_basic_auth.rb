# typed: strict
# frozen_string_literal: true

class TenantBasicAuth < ApplicationRecord
  extend T::Sig

  has_secure_password validations: false

  belongs_to :tenant, primary_key: :id

  validates :username, presence: true, if: :enabled?
  validates :password, presence: true, if: :password_required?

  sig { params(input_username: String, input_password: String).returns(T::Boolean) }
  def authenticate_credentials(input_username, input_password)
    return false unless enabled?

    username == input_username && authenticate(input_password).present?
  end

  private

  sig { returns(T::Boolean) }
  def password_required?
    enabled? && password_digest_changed?
  end
end
