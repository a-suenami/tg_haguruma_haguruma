# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: content_type_field_select_options
#
#  id              :bigint           not null, primary key
#  field_select_id :bigint           not null
#  unique_name     :string           not null
#  display_name    :text             not null
#  position        :integer          default(0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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
    return if identifier.blank?
    return if marked_for_destruction?
    return if field_select.blank?

    siblings = field_select.options.reject(&:marked_for_destruction?)
    duplicate = siblings.find do |sibling|
      sibling != self && sibling.identifier == identifier
    end

    errors.add(:identifier, :taken) if duplicate
  end
end
