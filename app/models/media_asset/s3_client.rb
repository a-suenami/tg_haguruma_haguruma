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
        **client_options,
      ),
      T.nilable(Aws::S3::Client),
    )
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def client_options
    options = {}
    endpoint = Settings.aws.s3.media.endpoint
    options[:endpoint] = endpoint if endpoint.present?
    # MinIO等のローカルストレージではパススタイルURLを使用
    force_path_style = Settings.aws.s3.media.force_path_style
    options[:force_path_style] = true if force_path_style.to_s == 'true' || force_path_style == true
    options
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

  sig { params(source_key: String, destination_key: String).returns(String) }
  def copy(source_key:, destination_key:)
    client.copy_object(
      bucket: bucket_name,
      copy_source: "#{bucket_name}/#{source_key}",
      key: destination_key,
    )
    destination_key
  end

  sig { params(key: String, expires_in: Integer).returns(String) }
  def presigned_url(key, expires_in: 3600)
    # presigned URLは外部公開用エンドポイントで署名する必要がある
    signer = Aws::S3::Presigner.new(client: public_client)
    signer.presigned_url(
      :get_object,
      bucket: bucket_name,
      key:,
      expires_in:,
    )
  end

  # 外部公開用クライアント（presigned URL生成用）
  sig { returns(Aws::S3::Client) }
  def public_client
    @public_client ||= T.let(
      Aws::S3::Client.new(
        region: Settings.aws.s3.media.region,
        credentials:,
        **public_client_options,
      ),
      T.nilable(Aws::S3::Client),
    )
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def public_client_options
    options = {}
    # 外部公開用エンドポイントがあればそれを使用、なければ内部エンドポイント
    public_endpoint = Settings.aws.s3.media.public_endpoint
    internal_endpoint = Settings.aws.s3.media.endpoint
    endpoint = public_endpoint.presence || internal_endpoint
    options[:endpoint] = endpoint if endpoint.present?
    force_path_style = Settings.aws.s3.media.force_path_style
    options[:force_path_style] = true if force_path_style.to_s == 'true' || force_path_style == true
    options
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
