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
#  tenant_id             :citext           not null
#  text_id               :integer
#
# Foreign Keys
#
#  fk_content_entry_fields_content_entry_versions  ([tenant_id, content_type_id, content_entry_id, version] => content_entry_versions[tenant_id, content_type_id, content_entry_id, version])
#  fk_content_entry_fields_content_type_fields     ([tenant_id, content_type_id, content_type_field_id, field_type] => content_type_fields[tenant_id, content_type_id, id, field_type])
#  fk_content_entry_fields_media_assets            ([tenant_id, media_asset_id] => content_entry_field_media_assets[tenant_id, id])
#  fk_rails_...                                    (richtext_id => content_entry_field_richtexts.id)
#  fk_rails_...                                    (text_id => content_entry_field_texts.id)
#
class ContentEntry::Field < ApplicationRecord
  include Multitenancy

  FIELD_TYPES = {
    text: 1,
    richtext: 2,
    media_asset: 3,
  }.freeze

  belongs_to :content_type_field, class_name: 'ContentType::Field'
  belongs_to :text, class_name: 'ContentEntry::FieldText', optional: true
  belongs_to :richtext, class_name: 'ContentEntry::FieldRichtext', optional: true
  belongs_to :media_asset, class_name: 'ContentEntry::FieldMediaAsset', optional: true
  validates :content_type_id, presence: true
  validates :content_entry_id, presence: true
  validates :version, presence: true
  validates :field_type, presence: true

  enum :field_type, FIELD_TYPES

  # Returns array of validation errors for this field (for publish validation)
  # @return [Array<String>] validation error messages
  def validation_errors
    errors_list = []

    if content_type_field.required && field_value_blank?
      errors_list << "#{content_type_field.label}は必須です"
    end

    errors_list
  end

  # Returns whether this field is valid for publishing
  # @return [Boolean]
  def valid_for_publish?
    validation_errors.empty?
  end

  # Returns the actual value of this field
  # @return [Object, nil]
  def field_value
    case field_type
    when 'text'
      text&.value
    when 'richtext'
      richtext&.value
    when 'media_asset'
      media_asset&.media_asset_id
    end
  end

  private

  # Returns whether the field value is blank
  # @return [Boolean]
  def field_value_blank?
    case field_type
    when 'text'
      text.nil? || text.value.blank?
    when 'richtext'
      richtext.nil? || richtext_content_blank?
    when 'media_asset'
      media_asset.nil?
    else
      true
    end
  end

  # Checks if richtext content is empty (handles Lexical JSON structure)
  # @return [Boolean]
  def richtext_content_blank?
    return true if richtext.value.blank?

    # Handle both formats: {"html": "..."} and raw Lexical JSON
    value = richtext.value
    if value.is_a?(Hash)
      html_content = value['html'] || value[:html]
      return html_content.blank? || html_content == '<p></p>' if html_content.present?

      # Check Lexical JSON structure for empty content
      root = value['root'] || value[:root]
      return true if root.nil?

      children = root['children'] || root[:children] || []
      return true if children.empty?

      # Check if all paragraph children are empty
      children.all? do |child|
        child_children = child['children'] || child[:children] || []
        child_children.empty? || child_children.all? { |c| (c['text'] || c[:text]).to_s.strip.empty? }
      end
    else
      value.to_s.blank?
    end
  end

  def exactly_one_field_value_set
    set_values = [text_id, richtext_id, media_asset_id].compact.size
    if set_values != 1
      errors.add(:base, 'exactly one field value must be set')
    end
  end
end
