# typed: false

class ContentEntry::Field < ApplicationRecord
  FIELD_TYPES = {
    text: 1,
    richtext: 2,
    media_asset: 3
  }.freeze

  belongs_to :content_type_field, class_name: 'ContentType::Field'
  belongs_to :text, class_name: 'ContentEntry::FieldText', optional: true
  belongs_to :richtext, class_name: 'ContentEntry::FieldRichtext', optional: true
  belongs_to :media_asset, class_name: 'ContentEntry::FieldMediaAsset', optional: true

  validates :tenant_id, presence: true
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true
  validates :content_type_field_id, presence: true
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES.values }

  enum field_type: FIELD_TYPES

  private

  def exactly_one_field_value_set
    set_values = [text_id, richtext_id, media_asset_id].compact.size
    if set_values != 1
      errors.add(:base, "exactly one field value must be set")
    end
  end
end
