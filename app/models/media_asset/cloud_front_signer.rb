# typed: true
# frozen_string_literal: true

class MediaAsset::CloudFrontSigner
  extend T::Sig

  # 用途別の有効期限
  EXPIRATION_ADMIN = 1.day
  EXPIRATION_PUBLIC_IMAGE = 10.minutes
  EXPIRATION_PUBLIC_VIDEO = 30.minutes

  # 用途の種類
  Purpose = T.type_alias { T.any(Symbol, String) }
  PURPOSES = T.let(%i[admin public].freeze, T::Array[Symbol])

  sig { params(s3_object_path: String, purpose: Purpose, media_type: T.nilable(Symbol)).returns(String) }
  def signed_url(s3_object_path, purpose: :admin, media_type: nil)
    expiration = determine_expiration(purpose:, media_type:)
    signer.signed_url(
      url(s3_object_path),
      expires: Time.current + expiration,
    )
  end

  sig { params(s3_object_path: String).returns(String) }
  def url(s3_object_path)
    "https://#{host}/#{s3_object_path}"
  end

  private

  sig { params(purpose: Purpose, media_type: T.nilable(Symbol)).returns(ActiveSupport::Duration) }
  def determine_expiration(purpose:, media_type:)
    case purpose.to_sym
    when :admin
      EXPIRATION_ADMIN
    when :public
      case media_type
      when :video
        EXPIRATION_PUBLIC_VIDEO
      else
        EXPIRATION_PUBLIC_IMAGE
      end
    else
      EXPIRATION_ADMIN
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
