# typed: false

class User < ApplicationRecord
  belongs_to :oauth_provider
  has_many :session_tokens

  validates :tenant_id, presence: true
  validates :uid, presence: true
end
