# typed: false

# == Schema Information
#
# Table name: content_entry_authorizations
#
#  id                           :uuid             not null, primary key
#  version                      :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  content_authorization_tag_id :uuid             not null
#  content_entry_id             :uuid             not null
#  tenant_id                    :citext           not null
#
# Indexes
#
#  index_content_entry_authorizations_on_tag               (content_authorization_tag_id)
#  index_content_entry_authorizations_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#  index_content_entry_authorizations_unique               (tenant_id,content_entry_id,version,content_authorization_tag_id) UNIQUE
#
# Foreign Keys
#
#  fk_content_entry_authorizations_versions  ([content_entry_id, version] => content_entry_versions[content_entry_id, version])
#  fk_rails_...                              (content_authorization_tag_id => content_authorization_tags.id)
#  fk_rails_...                              (tenant_id => tenants.id)
#
class ContentEntryAuthorization < ApplicationRecord
  include Multitenancy

  belongs_to :content_entry_version,
    class_name: 'ContentEntry::Version',
    foreign_key: [:content_entry_id, :version],
    primary_key: [:content_entry_id, :version],
    inverse_of: :content_entry_authorizations
  belongs_to :content_authorization_tag

  validates :content_entry_id, presence: true
  validates :version, presence: true, numericality: { greater_than: 0 }
  validates :content_authorization_tag_id,
    uniqueness: { scope: [:tenant_id, :content_entry_id, :version] }
end
