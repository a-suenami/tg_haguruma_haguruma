# typed: strict

class Auth0Account < ApplicationRecord
  extend T::Sig

  has_many :admin_auth0_accounts, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_many :admins, through: :admin_auth0_accounts

  has_many :ruler_auth0_accounts, class_name: 'Ruler::Auth0Account', dependent: :destroy
  has_many :rulers, through: :ruler_auth0_accounts

  validates :uid, presence: true, uniqueness: true
  validates :email, presence: true
end
