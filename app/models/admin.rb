# typed: strict

class Admin < ApplicationRecord
  extend T::Sig

  belongs_to :tenant

  has_many :admin_auth0_accounts, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_many :auth0_accounts, through: :admin_auth0_accounts

  validates :tenant_id, presence: true
end
