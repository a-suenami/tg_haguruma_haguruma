# typed: strict

class Admin::Auth0Account < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :admin
  belongs_to :auth0_account, class_name: '::Auth0Account'

  validates :admin_id, uniqueness: true
end
