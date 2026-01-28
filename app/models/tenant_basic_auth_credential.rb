# typed: strict
# frozen_string_literal: true

# == Schema Information
#
# Table name: tenant_basic_auth_credentials
#
#  id                   :uuid             not null, primary key
#  description          :string           default(""), not null
#  password_digest      :string           not null
#  username             :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  tenant_basic_auth_id :uuid             not null
#
# Indexes
#
#  idx_on_tenant_basic_auth_id_username_dcd4020202              (tenant_basic_auth_id,username) UNIQUE
#  index_tenant_basic_auth_credentials_on_tenant_basic_auth_id  (tenant_basic_auth_id)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_basic_auth_id => tenant_basic_auths.id)
#
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
