# typed: false

class User < ApplicationRecord
  belongs_to :oauth_provider
  has_many :session_tokens

  validates :tenant_id, presence: true
  validates :uid, presence: true
  validates :oauth_provider_id, presence: true
end
