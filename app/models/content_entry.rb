# typed: false

class ContentEntry < ApplicationRecord
  belongs_to :content_type
  has_many :versions, class_name: 'ContentEntry::Version', dependent: :destroy
  has_many :content_tags, dependent: :destroy, foreign_key: :content_id, inverse_of: :content_entry

  validates :tenant_id, presence: true
  validates :content_type_id, presence: true

  # マルチテナント対応
  default_scope { where(tenant_id: Tenant.current_id) if Tenant.current_id.present? }
end
