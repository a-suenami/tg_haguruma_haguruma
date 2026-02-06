# typed: true
# frozen_string_literal: true

class MediaAssets::CopyService
  extend T::Sig

  sig { void }
  def initialize
    @s3_client = T.let(MediaAsset::S3Client.new, MediaAsset::S3Client)
  end

  # Copy a private asset to the public folder
  # @param media_asset [MediaAsset] the media asset to copy
  # @return [String] the public S3 path
  sig { params(media_asset: MediaAsset).returns(String) }
  def copy_to_public(media_asset:)
    # Skip if already has a public copy
    existing_path = media_asset.public_s3_object_path
    return existing_path if existing_path.present?

    # Generate the public path
    public_path = generate_public_path(media_asset.s3_object_path)

    # Copy the object in S3
    @s3_client.copy(
      source_key: media_asset.s3_object_path,
      destination_key: public_path,
    )

    # Update the media asset with the public path
    media_asset.update!(public_s3_object_path: public_path)

    public_path
  end

  # Delete the public copy of an asset
  # @param media_asset [MediaAsset] the media asset whose public copy to delete
  # @return [Boolean] true if deleted, false if no copy existed
  sig { params(media_asset: MediaAsset).returns(T::Boolean) }
  def delete_public_copy(media_asset:)
    public_path = media_asset.public_s3_object_path
    return false if public_path.blank?

    # Delete from S3
    @s3_client.delete(key: public_path)

    # Clear the public path
    media_asset.update!(public_s3_object_path: nil)

    true
  end

  private

  # Generate the public S3 path from the original path
  # Converts: private/tenant_id/YYYY/MM/DD/uuid.ext -> public/tenant_id/YYYY/MM/DD/uuid.ext
  # Or for legacy paths: tenant_id/YYYY/MM/DD/uuid.ext -> public/tenant_id/YYYY/MM/DD/uuid.ext
  sig { params(original_path: String).returns(String) }
  def generate_public_path(original_path)
    # Remove private/ prefix if present
    base_path = original_path.sub(%r{^private/}, '')
    "public/#{base_path}"
  end
end
