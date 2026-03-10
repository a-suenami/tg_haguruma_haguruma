# typed: false

# == Schema Information
#
# Table name: content_entry_fields
#
#  id                    :bigint           not null, primary key
#  field_type            :integer          not null
#  version               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  content_entry_id      :uuid             not null
#  content_type_field_id :integer          not null
#  content_type_id       :uuid             not null
#  media_asset_id        :integer
#  richtext_id           :integer
#  select_id             :bigint
#  tenant_id             :citext           not null
#  text_id               :integer
#
# Foreign Keys
#
#  fk_content_entry_fields_content_entry_versions  ([tenant_id, content_type_id, content_entry_id, version] => content_entry_versions[tenant_id, content_type_id, content_entry_id, version])
#  fk_content_entry_fields_content_type_fields     ([tenant_id, content_type_id, content_type_field_id, field_type] => content_type_fields[tenant_id, content_type_id, id, field_type])
#  fk_content_entry_fields_media_assets            ([tenant_id, media_asset_id] => content_entry_field_media_assets[tenant_id, id])
#  fk_content_entry_fields_selects                 ([tenant_id, select_id] => content_entry_field_selects[tenant_id, id])
#  fk_rails_...                                    (richtext_id => content_entry_field_richtexts.id)
#  fk_rails_...                                    (text_id => content_entry_field_texts.id)
#
class ContentEntry::Field < ApplicationRecord
  include Multitenancy

  FIELD_TYPES = {
    text: 1,
    richtext: 2,
    media_asset: 3,
    select_field: 4,
  }.freeze

  belongs_to :content_type_field, class_name: 'ContentType::Field'
  belongs_to :text, class_name: 'ContentEntry::FieldText', optional: true
  belongs_to :richtext, class_name: 'ContentEntry::FieldRichtext', optional: true
  belongs_to :media_asset, class_name: 'ContentEntry::FieldMediaAsset', optional: true
  belongs_to :select, class_name: 'ContentEntry::FieldSelect', optional: true
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true
  validates :field_type, presence: true

  enum :field_type, FIELD_TYPES

  private

  def exactly_one_field_value_set
    set_values = [text_id, richtext_id, media_asset_id, select_id].compact.size
    if set_values != 1
      errors.add(:base, 'exactly one field value must be set')
    end
  end
end
