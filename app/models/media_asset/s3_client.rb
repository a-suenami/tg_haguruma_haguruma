# typed: true
# frozen_string_literal: true

class MediaAsset::S3Client
  extend T::Sig

  sig { returns(Aws::S3::Client) }
  def client
    @client ||= T.let(
      Aws::S3::Client.new(
        region: Settings.aws.s3.media.region,
        credentials:,
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
      key:,
      body:,
      content_type:,
    )
    key
  end

  sig { params(key: String).void }
  def delete(key:)
    client.delete_object(
      bucket: bucket_name,
      key:,
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
