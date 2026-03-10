# typed: false

# == Schema Information
#
# Table name: content_entry_field_texts
#
#  id    :bigint           not null, primary key
#  value :text             not null
#
class ContentEntry::FieldText < ApplicationRecord
  validates :value, presence: true
end
