# typed: false

# == Schema Information
#
# Table name: content_types
#
#  id            :uuid             not null, primary key
#  description   :text
#  display_name  :text
#  is_collection :boolean          default(TRUE), not null
#  unique_name   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :citext           not null
#
# Indexes
#
#  index_content_types_on_id_and_tenant_id  (id,tenant_id) UNIQUE
#  index_content_types_on_tenant_id_and_id  (tenant_id,id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class ContentType < ApplicationRecord
  include Multitenancy

  has_many :fields, -> { order(:position) }, dependent: :destroy, inverse_of: :content_type
  has_many :content_entries, dependent: :destroy

  accepts_nested_attributes_for :fields, allow_destroy: true, reject_if: :all_blank

  # TODO: Add unique index after data migration (see db/schemas/content_types.schema)
  validates :unique_name, presence: true, length: { maximum: 32 }, uniqueness: { scope: :tenant_id } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :display_name, presence: true, length: { maximum: 255 }
  validates :is_collection, inclusion: { in: [true, false] }
  validates :preview_url, format: { with: %r{\A/}, message: :must_start_with_slash }, allow_blank: true
  validate :validate_preview_url_placeholders

  scope :collections, -> { where(is_collection: true) }
  scope :singles, -> { where(is_collection: false) }

  # Find conflicting content type for uniqueness validation
  def conflicting_content_type
    return nil unless errors[:unique_name].any?
    return nil if unique_name.blank?

    ContentType.unscoped
               .where(tenant_id:, unique_name:)
               .where.not(id:)
               .first
  end

  private

  # Validate preview_url placeholder syntax
  def validate_preview_url_placeholders
    return if preview_url.blank?

    # Extract all placeholders (words starting with :)
    placeholders = preview_url.scan(/:(\w+)/).flatten
    valid_placeholders = %w[content_entry_id content_type_id]
    invalid = placeholders - valid_placeholders

    return if invalid.empty?

    errors.add(:preview_url, "contains invalid placeholders: #{invalid.join(', ')}. Valid: #{valid_placeholders.join(', ')}")
  end
end
