# typed: strict

class Admin < ApplicationRecord
  extend T::Sig

  belongs_to :tenant

  has_one :admin_auth0_account, class_name: 'Admin::Auth0Account', dependent: :destroy
  has_one :auth0_account, through: :admin_auth0_account

  # Validations
  validates :name, presence: true

  sig { returns(T.nilable(String)) }
  def email
    auth0_account&.email
  end
end
