# typed: strict
# frozen_string_literal: true

module MediaStorage
  class S3Client
    extend T::Sig

    sig { returns(Aws::S3::Client) }
    def client
      @client ||= T.let(
        Aws::S3::Client.new(
          region: Settings.aws.s3.media.region,
          credentials: credentials,
        ),
        T.nilable(Aws::S3::Client),
      )
    end

    sig { returns(String) }
    def bucket_name
      Settings.aws.s3.media.bucket_name
    end

    sig { params(key: String, body: T.any(String, StringIO, IO), content_type: String).returns(String) }
    def upload(key:, body:, content_type:)
      client.put_object(
        bucket: bucket_name,
        key: key,
        body: body,
        content_type: content_type,
      )
      key
    end

    sig { params(key: String).void }
    def delete(key:)
      client.delete_object(
        bucket: bucket_name,
        key: key,
      )
    end

    private

    sig { returns(T.any(Aws::Credentials, Aws::ECSCredentials)) }
    def credentials
      if Settings.aws.s3.media.use_ecs_credentials
        Aws::ECSCredentials.new
      else
        Aws::Credentials.new(
          Settings.aws.s3.media.access_key_id,
          Settings.aws.s3.media.secret_access_key,
        )
      end
    end
  end

  class CloudFrontSigner
    extend T::Sig

    SIGNED_URL_EXPIRATION = 7.days

    sig { params(s3_object_path: String).returns(String) }
    def signed_url(s3_object_path)
      signer.signed_url(
        url(s3_object_path),
        expires: Time.current + SIGNED_URL_EXPIRATION,
      )
    end

    sig { params(s3_object_path: String).returns(String) }
    def url(s3_object_path)
      "https://#{host}/#{s3_object_path}"
    end

    private

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
          key_pair_id: key_pair_id,
          private_key: private_key,
        ),
        T.nilable(Aws::CloudFront::UrlSigner),
      )
    end
  end

  class Uploader
    extend T::Sig

    sig { void }
    def initialize
      @s3_client = T.let(S3Client.new, S3Client)
      @cloudfront_signer = T.let(CloudFrontSigner.new, CloudFrontSigner)
    end

    sig do
      params(
        file: ActionDispatch::Http::UploadedFile,
        tenant_id: String,
      ).returns({ s3_object_path: String, url: String, media_asset: MediaAsset })
    end
    def upload(file:, tenant_id:)
      s3_object_path = generate_s3_path(file: file, tenant_id: tenant_id)

      # S3にアップロード
      @s3_client.upload(
        key: s3_object_path,
        body: file.read,
        content_type: file.content_type,
      )
      file.rewind

      # MediaAssetを作成
      media_asset = create_media_asset(
        file: file,
        tenant_id: tenant_id,
        s3_object_path: s3_object_path,
      )

      # CloudFront URLを生成
      url = @cloudfront_signer.signed_url(s3_object_path)

      {
        s3_object_path: s3_object_path,
        url: url,
        media_asset: media_asset,
      }
    end

    sig { params(s3_object_path: String).returns(String) }
    def url_for(s3_object_path)
      @cloudfront_signer.signed_url(s3_object_path)
    end

    private

    sig { params(file: ActionDispatch::Http::UploadedFile, tenant_id: String).returns(String) }
    def generate_s3_path(file:, tenant_id:)
      timestamp = Time.current.strftime('%Y/%m/%d')
      uuid = SecureRandom.uuid
      extension = File.extname(file.original_filename)

      "#{tenant_id}/#{timestamp}/#{uuid}#{extension}"
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
        tenant_id: tenant_id,
        mime_type: file.content_type,
        media_type: MediaAsset.detect_media_type(file.content_type),
        metadata: {
          filename: file.original_filename,
          file_size: file.size,
          s3_object_path: s3_object_path,
          uploaded_at: Time.current.iso8601,
        },
      )
    end
  end
end
