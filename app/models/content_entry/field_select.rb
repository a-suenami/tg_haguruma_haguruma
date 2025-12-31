# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entry_field_selects
#
#  id         :bigint           not null, primary key
#  tenant_id  :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ContentEntry::FieldSelect < ApplicationRecord
  has_many :selections,
           class_name: 'ContentEntry::FieldSelectSelection',
           foreign_key: :content_entry_field_select_id,
           dependent: :destroy,
           inverse_of: :field_select

  has_many :selected_options,
           through: :selections,
           source: :option,
           class_name: 'ContentType::FieldSelectOption'

  def selected_option_ids
    selections.pluck(:option_id)
  end

  def selected_option_ids=(ids)
    ids = Array(ids).compact_blank.map(&:to_i)
    self.selections = ids.map do |option_id|
      ContentEntry::FieldSelectSelection.new(option_id:)
    end
  end
end
