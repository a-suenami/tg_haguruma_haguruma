# typed: strict

# == Schema Information
#
# Table name: admins
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenant_id  :citext           not null
#
# Indexes
#
#  idx_admins_tenant_id  (tenant_id)
#
# Foreign Keys
#
#  fk_admins_tenants  (tenant_id => tenants.id)
#
class Admin < ApplicationRecord
  extend T::Sig
  include Multitenancy

  has_one :admin_auth0_account, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_one :auth0_account, through: :admin_auth0_account

  # Validations
  validates :name, presence: true

  sig { returns(T.nilable(String)) }
  def email
    auth0_account&.email
  end
end
