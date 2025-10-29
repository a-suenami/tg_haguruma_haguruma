# frozen_string_literal: true

class OauthProvider < ApplicationRecord
  belongs_to :tenant, primary_key: :id, foreign_key: :tenant_id
  has_many :users

  validates :tenant_id, presence: true
  validates :client_id, presence: true
  validates :endpoint_base, presence: true
end
