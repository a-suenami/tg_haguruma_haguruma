# typed: false

class ContentAuthorizationTag < ApplicationRecord
  include Multitenancy

  has_many :user_tags, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :remote_id, uniqueness: { scope: :tenant_id, allow_nil: true }
end
