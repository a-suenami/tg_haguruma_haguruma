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
  validates :api_identifier, presence: true, length: { maximum: 32 }
  validates :label, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true

  enum :field_type, FIELD_TYPES
end
