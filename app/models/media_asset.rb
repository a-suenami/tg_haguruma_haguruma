# typed: false

class MediaAsset < ApplicationRecord
  enum media_type: {
    image: 1,
    video: 2,
    audio: 3,
    document: 4
  }

  validates :tenant_id, presence: true
  validates :media_type, presence: true
  validates :mime_type, presence: true
  validates :metadata, presence: true
end
