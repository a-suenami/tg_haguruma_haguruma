# typed: false

# == Schema Information
#
# Table name: content_entry_field_richtexts
#
#  id    :bigint           not null, primary key
#  value :jsonb            not null
#
class ContentEntry::FieldRichtext < ApplicationRecord
  validates :value, presence: true
end
