# typed: strict

# == Schema Information
#
# Table name: auth0_accounts
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  idx_auth0_accounts_email_uniq  (email) UNIQUE
#  idx_auth0_accounts_uid_uniq    (uid) UNIQUE
#
class Auth0Account < ApplicationRecord
  extend T::Sig

  # One auth0_account can be admin of multiple tenants (1-to-many)
  has_many :admin_auth0_accounts, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_many :admins, through: :admin_auth0_accounts

  # One auth0_account can only be one ruler (1-to-1)
  has_one :ruler_auth0_account, class_name: 'Ruler::Auth0Account', dependent: :destroy
  has_one :ruler, through: :ruler_auth0_account

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
