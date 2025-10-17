# typed: false

class ContentEntry::FieldMediaAsset < ApplicationRecord
  enum :media_type, {
    image: 1,
    video: 2,
    audio: 3,
    document: 4,
  }

  validates :media_type, presence: true
  validates :s3_object_path, presence: true
end
