# typed: false

class ContentEntry::Version < ApplicationRecord
  STATUSES = {
    draft: 1,
    preview: 2,
    published: 3,
    unpublished: 4,
  }.freeze

  has_many :fields, dependent: :destroy

  validates :tenant_id, presence: true
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES.values }

  enum :status, STATUSES

  scope :drafts, -> { where(status: STATUSES[:draft]) }
  scope :previews, -> { where(status: STATUSES[:preview]) }
  scope :published, -> { where(status: STATUSES[:published]) }
  scope :unpublished, -> { where(status: STATUSES[:unpublished]) }
end
