# typed: false

class ContentEntry::FieldRichtext < ApplicationRecord

  validates :value, presence: true
end
