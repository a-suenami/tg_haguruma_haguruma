# typed: false
# frozen_string_literal: true

class OauthProvider < ApplicationRecord
  belongs_to :tenant, primary_key: :id
  has_many :users

  validates :client_id, presence: true
  validates :endpoint_base, presence: true
end
