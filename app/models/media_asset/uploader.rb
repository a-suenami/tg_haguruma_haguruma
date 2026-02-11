# typed: true
# frozen_string_literal: true

class MediaAsset::Uploader
  extend T::Sig

  sig { void }
  def initialize
    @s3_client = T.let(MediaAsset::S3Client.new, MediaAsset::S3Client)
    @cloudfront_signer = T.let(MediaAsset::CloudFrontSigner.new, MediaAsset::CloudFrontSigner)
  end

  sig do
    params(
      file: ActionDispatch::Http::UploadedFile,
      tenant_id: String,
    ).returns({ s3_object_path: String, url: String, media_asset: MediaAsset })
  end
  def upload(file:, tenant_id:)
    s3_object_path = generate_s3_path(file:, tenant_id:)

    # S3にアップロード
    @s3_client.upload(
      key: s3_object_path,
      body: file.read,
      content_type: file.content_type,
    )
    file.rewind

    # MediaAssetを作成
    media_asset = create_media_asset(
      file:,
      tenant_id:,
      s3_object_path:,
    )

    # CloudFront URLを生成 (always signed for private storage)
    url = @cloudfront_signer.signed_url(s3_object_path)

    {
      s3_object_path:,
      url:,
      media_asset:,
    }
  end

  sig do
    params(
      s3_object_path: String,
      purpose: MediaAsset::CloudFrontSigner::Purpose,
      media_type: T.nilable(Symbol),
    ).returns(String)
  end
  def url_for(s3_object_path, purpose: :admin, media_type: nil)
    @cloudfront_signer.signed_url(s3_object_path, purpose:, media_type:)
  end

  # Generate public URL for a given S3 path
  def public_url_for(s3_object_path)
    @cloudfront_signer.public_url(s3_object_path)
  end

  private

  sig do
    params(
      file: ActionDispatch::Http::UploadedFile,
      tenant_id: String,
    ).returns(String)
  end
  def generate_s3_path(file:, tenant_id:)
    timestamp = Time.current.strftime('%Y/%m/%d')
    uuid = SecureRandom.uuid
    extension = File.extname(file.original_filename)

    "private/#{tenant_id}/#{timestamp}/#{uuid}#{extension}"
  end

  sig do
    params(
      file: ActionDispatch::Http::UploadedFile,
      tenant_id: String,
      s3_object_path: String,
    ).returns(MediaAsset)
  end
  def create_media_asset(file:, tenant_id:, s3_object_path:)
    MediaAsset.create!(
      tenant_id:,
      mime_type: file.content_type,
      media_type: MediaAsset.detect_media_type(file.content_type),
      file_size_bytes: file.size,
      s3_object_path:,
      metadata: {
        original_filename: file.original_filename,
      },
    )
  end
end
