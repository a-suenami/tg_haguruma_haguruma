# typed: strict

# == Schema Information
#
# Table name: admin_auth0_accounts
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  admin_id         :uuid             not null
#  auth0_account_id :uuid             not null
#  tenant_id        :citext           not null
#
# Indexes
#
#  idx_admin_auth0_accounts_admin_uniq             (admin_id) UNIQUE
#  idx_admin_auth0_accounts_tenant                 (tenant_id)
#  index_admin_auth0_accounts_on_auth0_account_id  (auth0_account_id)
#
# Foreign Keys
#
#  fk_admin_auth0_accounts_admins          (admin_id => admins.id)
#  fk_admin_auth0_accounts_auth0_accounts  (auth0_account_id => auth0_accounts.id)
#  fk_admin_auth0_accounts_tenants         (tenant_id => tenants.id)
#
class Admin::Auth0Account < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :admin
  belongs_to :auth0_account, class_name: '::Auth0Account'

  validates :admin_id, uniqueness: true
end
