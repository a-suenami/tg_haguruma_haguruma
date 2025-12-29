# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_type_field_selects
#
#  id                :bigint           not null, primary key
#  display_format    :integer          default(0), not null
#  default_option_id :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class ContentType::FieldSelect < ApplicationRecord
  DISPLAY_FORMATS = {
    dropdown: 0,
    checkbox: 1,
    radio: 2,
  }.freeze

  has_many :options,
           class_name: 'ContentType::FieldSelectOption',
           dependent: :destroy,
           inverse_of: :field_select

  belongs_to :default_option,
             class_name: 'ContentType::FieldSelectOption',
             optional: true

  enum :display_format, DISPLAY_FORMATS

  accepts_nested_attributes_for :options, allow_destroy: true

  validates :display_format, presence: true

  def display_format_label
    case display_format
    when 'dropdown'
      I18n.t('ruler_area.content_types.select_display_formats.dropdown')
    when 'checkbox'
      I18n.t('ruler_area.content_types.select_display_formats.checkbox')
    when 'radio'
      I18n.t('ruler_area.content_types.select_display_formats.radio')
    else
      display_format
    end
  end

  def multi_select?
    checkbox?
  end
end
