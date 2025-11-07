# typed: strict

class Ruler < ApplicationRecord
  extend T::Sig

  has_one :ruler_auth0_account, class_name: 'Ruler::Auth0Account', dependent: :destroy
  has_one :auth0_account, through: :ruler_auth0_account

  sig { returns(T.nilable(String)) }
  def email
    auth0_account&.email
  end
end
