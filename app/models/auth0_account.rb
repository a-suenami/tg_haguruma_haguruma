# typed: strict

class Auth0Account < ApplicationRecord
  extend T::Sig

  # 1 auth0_account có thể là admin của nhiều tenants
  has_many :admin_auth0_accounts, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_many :admins, through: :admin_auth0_accounts

  # 1 auth0_account chỉ có thể là 1 ruler (1-to-1)
  has_one :ruler_auth0_account, class_name: 'Ruler::Auth0Account', dependent: :destroy
  has_one :ruler, through: :ruler_auth0_account

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
