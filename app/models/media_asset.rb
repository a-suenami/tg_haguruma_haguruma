# typed: false

# == Schema Information
#
# Table name: media_assets
#
#  id                    :uuid             not null, primary key
#  file_size_bytes       :bigint           not null
#  media_type            :integer          not null
#  metadata              :jsonb            not null
#  mime_type             :string           not null
#  public_s3_object_path :string
#  s3_object_path        :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_id             :citext           not null
#
# Indexes
#
#  index_media_assets_on_id_and_media_type                (id,media_type) UNIQUE
#  index_media_assets_on_tenant_id_and_id_and_media_type  (tenant_id,id,media_type) UNIQUE
#  index_media_assets_on_tenant_id_and_media_type_and_id  (tenant_id,media_type,id) UNIQUE
#
class MediaAsset < ApplicationRecord
  include Multitenancy

  enum :media_type, {
    image: 1,
    video: 2,
    audio: 3,
    document: 4,
  }

  validates :media_type, presence: true
  validates :mime_type, presence: true
  validates :file_size_bytes, presence: true
  validates :s3_object_path, presence: true
  validates :metadata, presence: true

  scope :images, -> { where(media_type: :image) }
  scope :videos, -> { where(media_type: :video) }
  scope :audios, -> { where(media_type: :audio) }
  scope :documents, -> { where(media_type: :document) }

  def original_filename
    metadata&.dig('original_filename') || ''
  end

  def content_type
    mime_type
  end

  def url
    return nil if s3_object_path.blank?

    uploader = MediaAsset::Uploader.new
    uploader.url_for(s3_object_path)
  end

  def public_url
    return nil if public_s3_object_path.blank?

    uploader = MediaAsset::Uploader.new
    uploader.public_url_for(public_s3_object_path)
  end

  # Check if this asset has a public copy
  def public_copy?
    public_s3_object_path.present?
  end

  def self.detect_media_type(mime_type)
    case mime_type
    when %r{^image/}
      :image
    when %r{^video/}
      :video
    when %r{^audio/}
      :audio
    else
      :document
    end
  end
end
