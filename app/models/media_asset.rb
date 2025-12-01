# typed: false

class MediaAsset < ApplicationRecord
  include Multitenancy

  has_one_attached :file

  enum :media_type, {
    image: 1,
    video: 2,
    audio: 3,
    document: 4,
  }

  validates :media_type, presence: true
  validates :mime_type, presence: true
  validates :metadata, presence: true

  scope :images, -> { where(media_type: :image) }
  scope :videos, -> { where(media_type: :video) }
  scope :audios, -> { where(media_type: :audio) }
  scope :documents, -> { where(media_type: :document) }

  def filename
    metadata&.dig('filename') || file.filename.to_s
  end

  def file_size
    metadata&.dig('file_size') || file.byte_size
  end

  def content_type
    mime_type
  end

  def self.detect_media_type(mime_type)
    case mime_type
    when /^image\//
      :image
    when /^video\//
      :video
    when /^audio\//
      :audio
    else
      :document
    end
  end
end
