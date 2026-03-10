# typed: true
# frozen_string_literal: true

class MediaAsset::CloudFrontSigner
  extend T::Sig

  EXPIRATION_DEFAULT = 10.minutes
  EXPIRATION_VIDEO = 30.minutes

  sig { params(s3_object_path: String, media_type: T.nilable(Symbol)).returns(String) }
  def signed_url(s3_object_path, media_type: nil)
    return s3_presigned_url(s3_object_path, media_type:) unless cloudfront_configured?

    expiration = determine_expiration(media_type:)
    signer.signed_url(
      url(s3_object_path),
      expires: Time.current + expiration,
    )
  end

  sig { params(s3_object_path: String).returns(String) }
  def public_url(s3_object_path)
    return s3_presigned_url(s3_object_path) unless cloudfront_configured?

    url(s3_object_path)
  end

  sig { params(s3_object_path: String).returns(String) }
  def url(s3_object_path)
    "https://#{host}/#{s3_object_path}"
  end

  sig { params(s3_object_path: String, media_type: T.nilable(Symbol)).returns(String) }
  def s3_presigned_url(s3_object_path, media_type: nil)
    expiration = determine_expiration(media_type:)
    s3_client.presigned_url(s3_object_path, expires_in: expiration.to_i)
  end

  sig { returns(MediaAsset::S3Client) }
  def s3_client
    @s3_client ||= T.let(MediaAsset::S3Client.new, T.nilable(MediaAsset::S3Client))
  end

  private

  sig { returns(T::Boolean) }
  def cloudfront_configured?
    Settings.aws.cloudfront.media.host.present? &&
      Settings.aws.cloudfront.media.key_pair.private.public_key_id.present? &&
      Settings.aws.cloudfront.media.key_pair.private.private_key.present?
  end

  sig { params(media_type: T.nilable(Symbol)).returns(ActiveSupport::Duration) }
  def determine_expiration(media_type:)
    case media_type
    when :video
      EXPIRATION_VIDEO
    else
      EXPIRATION_DEFAULT
    end
  end

  sig { returns(String) }
  def host
    Settings.aws.cloudfront.media.host
  end

  sig { returns(String) }
  def key_pair_id
    Settings.aws.cloudfront.media.key_pair.private.public_key_id
  end

  sig { returns(String) }
  def private_key
    key = Settings.aws.cloudfront.media.key_pair.private.private_key
    raise 'CloudFront private key is not configured' if key.blank?

    key
  end

  sig { returns(Aws::CloudFront::UrlSigner) }
  def signer
    @signer ||= T.let(
      Aws::CloudFront::UrlSigner.new(
        key_pair_id:,
        private_key:,
      ),
      T.nilable(Aws::CloudFront::UrlSigner),
    )
  end
end
