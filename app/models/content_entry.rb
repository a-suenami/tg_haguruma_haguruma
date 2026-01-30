# typed: false

# == Schema Information
#
# Table name: content_entries
#
#  id               :uuid             not null, primary key
#  publication_date :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  content_type_id  :uuid             not null
#  tenant_id        :citext           not null
#
# Indexes
#
#  index_content_entries_on_tenant_id_and_content_type_id_and_id  (tenant_id,content_type_id,id) UNIQUE
#  index_content_entries_on_tenant_id_and_id                      (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  ([tenant_id, content_type_id] => content_types[tenant_id, id])
#
class ContentEntry < ApplicationRecord
  include Multitenancy

  belongs_to :content_type
  has_many :versions, class_name: 'ContentEntry::Version', dependent: :destroy
  has_many :content_tags, dependent: :destroy, foreign_key: :content_id, inverse_of: :content_entry

  # DEPRECATED: use ContentEntry::Version#custom_published_at
  # validates :publication_date, presence: true

  # Returns the latest published version (highest version number)
  # NOTE: Caller should eager load :versions to avoid N+1 queries
  def latest_published_version
    versions.select(&:published?).max_by(&:version)
  end

  # Returns the display date for user-facing pages
  def display_publication_date
    published_version = latest_published_version
    published_version&.custom_published_at || published_version&.published_at
  end
end
