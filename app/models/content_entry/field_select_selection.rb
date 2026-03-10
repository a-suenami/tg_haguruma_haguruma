# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_entry_field_select_selections
#
#  id                            :bigint           not null, primary key
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  content_entry_field_select_id :bigint           not null
#  option_id                     :bigint           not null
#
# Indexes
#
#  idx_field_select_selections_unique  (content_entry_field_select_id,option_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (content_entry_field_select_id => content_entry_field_selects.id)
#  fk_rails_...  (option_id => content_type_field_select_options.id)
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
