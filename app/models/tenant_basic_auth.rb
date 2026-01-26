# typed: strict
# frozen_string_literal: true

class TenantBasicAuth < ApplicationRecord
  extend T::Sig

  belongs_to :tenant, primary_key: :id
  has_many :credentials, class_name: 'TenantBasicAuthCredential', dependent: :destroy

  sig { params(input_username: String, input_password: String).returns(T::Boolean) }
  def authenticate_credentials(input_username, input_password)
    return false unless enabled?

    credential = credentials.find_by(username: input_username)
    return false unless credential

    credential.valid_password?(input_password)
  end
end
