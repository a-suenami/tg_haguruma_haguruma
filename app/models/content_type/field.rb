# typed: false

class ContentType::Field < ApplicationRecord
  FIELD_TYPES = {
    text: 1,
    richtext: 2,
    media_asset: 3,
  }.freeze

  belongs_to :content_type
  belongs_to :text, class_name: 'ContentType::FieldText', optional: true
  belongs_to :richtext, class_name: 'ContentType::FieldRichtext', optional: true
  belongs_to :media_asset, class_name: 'ContentType::FieldMediaAsset', optional: true

  validates :tenant_id, presence: true
  validates :api_identifier, presence: true, length: { maximum: 32 }, uniqueness: { scope: :content_type_id }
  validates :label, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true
  validates :required, inclusion: { in: [true, false] }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :api_identifier_unique_in_siblings

  enum :field_type, FIELD_TYPES

  # Order by position by default
  default_scope { order(:position) }

  # Auto-set position before create
  before_validation :set_position, on: :create

  private

  def api_identifier_unique_in_siblings
    return if api_identifier.blank?
    return if marked_for_destruction?

    # Check uniqueness among sibling fields (same content_type)
    siblings = if content_type.present?
      content_type.fields.reject(&:marked_for_destruction?)
    else
      []
    end

    duplicate = siblings.find do |sibling|
      sibling != self && sibling.api_identifier == api_identifier
    end

    if duplicate
      errors.add(:api_identifier, :taken)
    end
  end

  def set_position
    # Only auto-set if position is explicitly nil (not 0)
    return unless position.nil?

    # Query DB directly to get max position for this content_type
    max_position = ContentType::Field.unscoped
                                     .where(content_type_id:)
                                     .maximum(:position) || -1
    self.position = max_position + 1
  end
end
