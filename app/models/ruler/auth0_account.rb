# typed: strict

# == Schema Information
#
# Table name: ruler_auth0_accounts
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  auth0_account_id :uuid             not null
#  ruler_id         :uuid             not null
#
# Indexes
#
#  idx_ruler_auth0_accounts_ruler_uniq             (ruler_id) UNIQUE
#  index_ruler_auth0_accounts_on_auth0_account_id  (auth0_account_id)
#
# Foreign Keys
#
#  fk_ruler_auth0_accounts_auth0_accounts  (auth0_account_id => auth0_accounts.id)
#  fk_ruler_auth0_accounts_rulers          (ruler_id => rulers.id)
#
class Ruler::Auth0Account < ApplicationRecord
  extend T::Sig

  belongs_to :ruler
  belongs_to :auth0_account, class_name: '::Auth0Account'

  validates :ruler_id, uniqueness: true
end
