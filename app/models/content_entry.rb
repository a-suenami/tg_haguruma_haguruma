# typed: false

# == Schema Information
#
# Table name: content_entries
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  content_type_id :uuid             not null
#  tenant_id       :citext           not null
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

  # Display date for user page
  # Falls back to published version's published_at if publication_date is nil
  def display_publication_date
    publication_date || versions.published.order(published_at: :desc).first&.published_at
  end
end
