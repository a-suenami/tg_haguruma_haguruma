# typed: false

class UserTag < ApplicationRecord
  include Multitenancy

  belongs_to :user
  belongs_to :content_authorization_tag

  validates :content_authorization_tag_id, uniqueness: { scope: [:tenant_id, :user_id] }
end
