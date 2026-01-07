# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_type_field_select_options
#
#  id              :bigint           not null, primary key
#  display_name    :text             not null
#  position        :integer          default(0), not null
#  unique_name     :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  field_select_id :bigint           not null
#
# Indexes
#
#  idx_on_field_select_id_position_9d0ef88527     (field_select_id,position)
#  idx_on_field_select_id_unique_name_47572cb0f7  (field_select_id,unique_name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (field_select_id => content_type_field_selects.id)
#
class ContentType::FieldSelectOption < ApplicationRecord
  belongs_to :field_select,
             class_name: 'ContentType::FieldSelect',
             inverse_of: :options

  validates :display_name, presence: true, length: { maximum: 255 }
  validates :unique_name, presence: true, length: { maximum: 32 },
                          uniqueness: { scope: :field_select_id }
  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :identifier_unique_in_siblings

  scope :ordered, -> { order(:position) }

  before_validation :set_position, on: :create

  private

  def set_position
    return unless position.nil?

    max_position = self.class
                       .where(field_select_id:)
                       .maximum(:position) || 0
    self.position = max_position + 1
  end

  def identifier_unique_in_siblings
    return if unique_name.blank?
    return if marked_for_destruction?
    return if field_select.blank?

    siblings = field_select.options.reject(&:marked_for_destruction?)
    duplicate = siblings.find do |sibling|
      sibling != self && sibling.unique_name == unique_name
    end

    errors.add(:unique_name, :taken) if duplicate
  end
end
