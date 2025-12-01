# typed: false

class ContentType < ApplicationRecord
  include Multitenancy

  has_many :fields, -> { order(:position) }, dependent: :destroy, inverse_of: :content_type
  has_many :content_entries, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank

  validates :unique_name, presence: true, length: { maximum: 32 }, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true, length: { maximum: 255 }
  validates :is_collection, inclusion: { in: [true, false] }

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }
end
