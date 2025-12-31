# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entry_field_select_selections
#
#  id                            :bigint           not null, primary key
#  content_entry_field_select_id :bigint           not null
#  option_id                     :bigint           not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
class ContentEntry::FieldSelectSelection < ApplicationRecord
  belongs_to :field_select,
             class_name: 'ContentEntry::FieldSelect',
             foreign_key: :content_entry_field_select_id,
             inverse_of: :selections

  belongs_to :option,
             class_name: 'ContentType::FieldSelectOption'

  validates :option_id, uniqueness: { scope: :content_entry_field_select_id }
end
