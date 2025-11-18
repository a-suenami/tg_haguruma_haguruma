# typed: false

class ContentType < ApplicationRecord
  has_many :fields, dependent: :destroy
  has_many :content_entries, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank

  validates :tenant_id, presence: true
  validates :unique_name, presence: true, length: { maximum: 32 }, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true, length: { maximum: 255 }
  validates :is_collection, inclusion: { in: [true, false] }

  # マルチテナント対応
  default_scope { where(tenant_id: Tenant.current_id) if Tenant.current_id.present? }

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }

  # Find conflicting content type for uniqueness validation
  def conflicting_content_type
    return nil unless errors[:unique_name].any?
    return nil if unique_name.blank?

    ContentType.unscoped
               .where(tenant_id: tenant_id, unique_name: unique_name)
               .where.not(id: id)
               .first
  end
end
