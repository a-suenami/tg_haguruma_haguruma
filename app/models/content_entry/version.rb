# typed: false

# == Schema Information
#
# Table name: content_entry_versions
#
#  id               :bigint           not null, primary key
#  is_public        :boolean          default(FALSE), not null
#  published_at     :datetime
#  status           :integer          not null
#  unpublished_at   :datetime
#  version          :integer          default(1), not null
#  created_at       :datetime         not null
#  content_entry_id :uuid             not null
#  content_type_id  :uuid             not null
#  tenant_id        :citext           not null
#
# Indexes
#
#  index_content_entry_versions_on_entry_version              (content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_tenant_is_public           (tenant_id,is_public)
#  index_content_entry_versions_on_tenant_type_entry_version  (tenant_id,content_type_id,content_entry_id,version) UNIQUE
#
# Foreign Keys
#
#  fk_content_entry_versions_content_entries  ([tenant_id, content_type_id, content_entry_id] => content_entries[tenant_id, content_type_id, id])
#
class ContentEntry::Version < ApplicationRecord
  include Multitenancy

  STATUSES = {
    draft: 1,
    preview: 2,
    published: 3,
    unpublished: 4,
  }.freeze

  has_many :fields, class_name: 'ContentEntry::Field',
    foreign_key: [:tenant_id, :content_type_id, :content_entry_id, :version],
    primary_key: [:tenant_id, :content_type_id, :content_entry_id, :version],
    dependent: :destroy,
    inverse_of: false
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  enum :status, STATUSES

  scope :drafts, -> { where(status: STATUSES[:draft]) }
  scope :previews, -> { where(status: STATUSES[:preview]) }
  scope :published, -> { where(status: STATUSES[:published]) }
  scope :unpublished, -> { where(status: STATUSES[:unpublished]) }
end
