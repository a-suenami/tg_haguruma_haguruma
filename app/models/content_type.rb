# typed: false

class ContentType < ApplicationRecord
  has_many :fields, dependent: :destroy

  validates :tenant_id, presence: true
  validates :is_collection, inclusion: { in: [true, false] }

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }
end
