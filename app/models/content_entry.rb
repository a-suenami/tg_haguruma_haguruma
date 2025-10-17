# typed: false

class ContentEntry < ApplicationRecord
  has_many :content_tags, dependent: :destroy, foreign_key: :content_id

  validates :tenant_id, presence: true
  validates :content_type_id, presence: true
end
