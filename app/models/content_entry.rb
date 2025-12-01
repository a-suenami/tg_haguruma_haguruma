# typed: false

class ContentEntry < ApplicationRecord
  include Multitenancy

  belongs_to :content_type
  has_many :versions, class_name: 'ContentEntry::Version', dependent: :destroy
  has_many :content_tags, dependent: :destroy, foreign_key: :content_id, inverse_of: :content_entry
end
