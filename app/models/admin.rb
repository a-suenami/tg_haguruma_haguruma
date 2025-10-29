# typed: strict

class Admin < ApplicationRecord
  extend T::Sig

  belongs_to :tenant

  has_many :admin_auth0_accounts, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_many :auth0_accounts, through: :admin_auth0_accounts

  # Delegate email to first auth0_account (Admin doesn't have email column)
  delegate :email, to: :primary_auth0_account, allow_nil: true

  # Validations
  validates :name, presence: true

  # Get primary auth0_account (first linked account)
  sig { returns(T.nilable(::Auth0Account)) }
  def primary_auth0_account
    auth0_accounts.first
  end
end
