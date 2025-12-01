# typed: false

# == Schema Information
#
# Table name: content_type_fields
#
#  id              :bigint           not null, primary key
#  api_identifier  :text             not null
#  description     :text             default(""), not null
#  field_type      :integer          not null
#  label           :text             not null
#  position        :integer          default(0), not null
#  required        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  content_type_id :uuid             not null
#  media_asset_id  :integer
#  richtext_id     :integer
#  tenant_id       :citext           not null
#  text_id         :integer
#
# Indexes
#
#  idx_on_content_type_id_api_identifier_0e95c10a8a           (content_type_id,api_identifier) UNIQUE
#  idx_on_tenant_id_content_type_id_id_01457429a3             (tenant_id,content_type_id,id) UNIQUE
#  idx_on_tenant_id_content_type_id_id_field_type_db01de1ec3  (tenant_id,content_type_id,id,field_type) UNIQUE
#  index_content_type_fields_on_content_type_id_and_position  (content_type_id,position)
#
# Foreign Keys
#
#  fk_rails_...  ([tenant_id, content_type_id] => content_types[tenant_id, id])
#  fk_rails_...  (media_asset_id => content_type_field_media_assets.id)
#  fk_rails_...  (richtext_id => content_type_field_richtexts.id)
#  fk_rails_...  (text_id => content_type_field_texts.id)
#
class ContentType::Field < ApplicationRecord
  include Multitenancy

  FIELD_TYPES = {
    text: 1,
    richtext: 2,
    media_asset: 3,
  }.freeze

  belongs_to :content_type
  belongs_to :text, class_name: 'ContentType::FieldText', optional: true
  belongs_to :richtext, class_name: 'ContentType::FieldRichtext', optional: true
  belongs_to :media_asset, class_name: 'ContentType::FieldMediaAsset', optional: true

  validates :api_identifier, presence: true, length: { maximum: 32 }, uniqueness: { scope: :content_type_id }
  validates :label, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true
  validates :required, inclusion: { in: [true, false] }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  enum :field_type, FIELD_TYPES

  scope :ordered, -> { order(:position) }

  # Auto-set position before create
  before_validation :set_position, on: :create

  private

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
