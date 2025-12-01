# typed: false

class User < ApplicationRecord
  include Multitenancy

  belongs_to :oauth_provider
  has_many :session_tokens

  validates :uid, presence: true
end
