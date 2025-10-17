# typed: strict

class Ruler < ApplicationRecord
  extend T::Sig

  has_many :ruler_auth0_accounts, class_name: 'Ruler::Auth0Account', dependent: :destroy
  has_many :auth0_accounts, through: :ruler_auth0_accounts
end
