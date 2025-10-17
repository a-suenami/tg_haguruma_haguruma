# typed: false

class ContentEntry::FieldText < ApplicationRecord

  validates :value, presence: true
end
