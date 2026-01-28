# typed: false

# == Schema Information
#
# Table name: content_entry_versions
#
#  id                       :bigint           not null, primary key
#  is_public                :boolean          default(FALSE), not null
#  preview_token            :string
#  preview_token_expires_at :datetime
#  published_at             :datetime
#  status                   :integer          not null
#  unpublished_at           :datetime
#  version                  :integer          default(1), not null
#  visibility               :integer          default("public"), not null
#  created_at               :datetime         not null
#  content_entry_id         :uuid             not null
#  content_type_id          :uuid             not null
#  tenant_id                :citext           not null
#
# Indexes
#
#  index_content_entry_versions_on_entry_version              (content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_preview_token              (preview_token) UNIQUE WHERE (preview_token IS NOT NULL)
#  index_content_entry_versions_on_tenant_is_public           (tenant_id,is_public)
#  index_content_entry_versions_on_tenant_type_entry_version  (tenant_id,content_type_id,content_entry_id,version) UNIQUE
#  index_content_entry_versions_on_tenant_visibility          (tenant_id,visibility)
#  index_content_entry_versions_on_token_expires_at           (preview_token_expires_at) WHERE (preview_token IS NOT NULL)
#  index_content_entry_versions_unique_draft_per_entry        (content_entry_id) UNIQUE WHERE (status = 1)
#  index_content_entry_versions_unique_published_per_entry    (content_entry_id) UNIQUE WHERE (status = 3)
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

  VISIBILITIES = {
    public: 0,
    authenticated: 1,
    restricted: 2,
  }.freeze

  has_many :fields, class_name: 'ContentEntry::Field',
    foreign_key: [:tenant_id, :content_type_id, :content_entry_id, :version],
    primary_key: [:tenant_id, :content_type_id, :content_entry_id, :version],
    dependent: :destroy,
    inverse_of: false
  has_many :content_entry_authorizations,
    foreign_key: [:content_entry_id, :version],
    primary_key: [:content_entry_id, :version],
    dependent: :destroy,
    inverse_of: :content_entry_version
  has_many :content_authorization_tags, through: :content_entry_authorizations
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  enum :status, STATUSES
  enum :visibility, VISIBILITIES, prefix: true

  scope :drafts, -> { where(status: STATUSES[:draft]) }
  scope :previews, -> { where(status: STATUSES[:preview]) }
  scope :published, -> { where(status: STATUSES[:published]).where.not(published_at: nil) }
  scope :unpublished, -> { where(status: STATUSES[:unpublished]) }
end
