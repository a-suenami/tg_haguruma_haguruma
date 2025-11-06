# typed: strict

class Ruler::Auth0Account < ApplicationRecord
  extend T::Sig

  belongs_to :ruler
  belongs_to :auth0_account, class_name: '::Auth0Account'

  validates :ruler_id, uniqueness: true
end
