# typed: strict
# frozen_string_literal: true

# Cloudflare Stream クライアントモジュール
# 動画のアップロード、配信、使用量分析を提供
#
# Cloudflare Stream は以下の料金体系:
# - ストレージ: $5/1,000分
# - 配信: $1/1,000分
#
# テナント別課金の仕組み:
# - creator フィールドに tenant_id を設定
# - GraphQL Analytics API でテナント別・動画別の使用量を取得可能
#
# @see https://developers.cloudflare.com/stream/
module CloudflareStream
  # Cloudflare Stream APIクライアント
  class Client
    extend T::Sig

    BASE_URL = 'https://api.cloudflare.com/client/v4'
    GRAPHQL_URL = 'https://api.cloudflare.com/client/v4/graphql'

    sig { void }
    def initialize
      @account_id = T.let(Settings.cloudflare.stream.account_id, String)
      @api_token = T.let(Settings.cloudflare.stream.api_token, String)
      @connection = T.let(build_connection, Faraday::Connection)
    end

    # 動画一覧を取得
    sig { params(params: T::Hash[Symbol, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def list_videos(params = {})
      get("/accounts/#{@account_id}/stream", params)
    end

    # 動画詳細を取得
    sig { params(video_uid: String).returns(T::Hash[String, T.untyped]) }
    def get_video(video_uid)
      get("/accounts/#{@account_id}/stream/#{video_uid}")
    end

    # 動画をアップロード（Direct Creator Upload URL生成）
    # @param creator_id [String] テナントIDなど、動画の所有者を識別するID
    # @param max_duration_seconds [Integer] 最大動画長（秒）
    # @param meta [Hash] カスタムメタデータ
    sig do
      params(
        creator_id: String,
        max_duration_seconds: Integer,
        meta: T::Hash[Symbol, T.untyped],
      ).returns(T::Hash[String, T.untyped])
    end
    def create_direct_upload_url(creator_id:, max_duration_seconds: 3600, meta: {})
      post(
        "/accounts/#{@account_id}/stream/direct_upload",
        {
          maxDurationSeconds: max_duration_seconds,
          creator: creator_id,
          meta: meta,
        },
      )
    end

    # TUSプロトコル用のアップロードURL生成（200MB以上の動画用）
    sig do
      params(
        creator_id: String,
        upload_length: Integer,
        meta: T::Hash[Symbol, T.untyped],
      ).returns(T::Hash[String, T.untyped])
    end
    def create_tus_upload_url(creator_id:, upload_length:, meta: {})
      post(
        "/accounts/#{@account_id}/stream?direct_user=true",
        {},
        headers: {
          'Tus-Resumable' => '1.0.0',
          'Upload-Length' => upload_length.to_s,
          'Upload-Creator' => creator_id,
          'Upload-Metadata' => encode_tus_metadata(meta),
        },
      )
    end

    # 動画のメタデータを更新
    sig do
      params(
        video_uid: String,
        updates: T::Hash[Symbol, T.untyped],
      ).returns(T::Hash[String, T.untyped])
    end
    def update_video(video_uid, updates)
      post("/accounts/#{@account_id}/stream/#{video_uid}", updates)
    end

    # 動画を削除
    sig { params(video_uid: String).returns(T::Hash[String, T.untyped]) }
    def delete_video(video_uid)
      delete("/accounts/#{@account_id}/stream/#{video_uid}")
    end

    # creator_id で動画を検索
    sig { params(creator_id: String).returns(T::Hash[String, T.untyped]) }
    def list_videos_by_creator(creator_id)
      list_videos(creator: creator_id)
    end

    # GraphQL クエリを実行
    sig { params(query: String, variables: T::Hash[Symbol, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def graphql(query, variables = {})
      response = @connection.post(GRAPHQL_URL) do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = { query: query, variables: variables }.to_json
      end

      parse_response(response)
    end

    private

    sig { returns(Faraday::Connection) }
    def build_connection
      Faraday.new(url: BASE_URL) do |f|
        f.request :json
        f.response :json
        f.request :retry, max: 3, interval: 0.5
        f.headers['Authorization'] = "Bearer #{@api_token}"
        f.adapter Faraday.default_adapter
      end
    end

    sig { params(path: String, params: T::Hash[Symbol, T.untyped]).returns(T::Hash[String, T.untyped]) }
    def get(path, params = {})
      response = @connection.get(path, params)
      parse_response(response)
    end

    sig do
      params(
        path: String,
        body: T::Hash[Symbol, T.untyped],
        headers: T::Hash[String, String],
      ).returns(T::Hash[String, T.untyped])
    end
    def post(path, body, headers: {})
      response = @connection.post(path) do |req|
        req.headers.merge!(headers)
        req.body = body
      end
      parse_response(response)
    end

    sig { params(path: String).returns(T::Hash[String, T.untyped]) }
    def delete(path)
      response = @connection.delete(path)
      parse_response(response)
    end

    sig { params(response: Faraday::Response).returns(T::Hash[String, T.untyped]) }
    def parse_response(response)
      body = response.body
      return body if body.is_a?(Hash)

      { 'success' => false, 'errors' => [{ 'message' => 'Invalid response' }] }
    end

    sig { params(meta: T::Hash[Symbol, T.untyped]).returns(String) }
    def encode_tus_metadata(meta)
      meta.map { |k, v| "#{k} #{Base64.strict_encode64(v.to_s)}" }.join(',')
    end
  end

  # アナリティクスサービス
  # テナント別・動画別の使用量を取得
  class Analytics
    extend T::Sig

    sig { void }
    def initialize
      @client = T.let(Client.new, Client)
      @account_id = T.let(Settings.cloudflare.stream.account_id, String)
    end

    # 特定動画の視聴統計を取得
    # @note Stream Player使用時のみ有効（クライアントサイドメトリクス）
    sig do
      params(
        video_uid: String,
        date_start: Date,
        date_end: Date,
      ).returns(T::Hash[String, T.untyped])
    end
    def video_playback_stats(video_uid:, date_start:, date_end:)
      query = <<~GRAPHQL
        query($accountTag: String!, $uid: String!, $dateStart: Date!, $dateEnd: Date!) {
          viewer {
            accounts(filter: { accountTag: $accountTag }) {
              videoPlaybackEventsAdaptiveGroups(
                filter: {
                  date_geq: $dateStart
                  date_lt: $dateEnd
                  uid: $uid
                }
                limit: 1
              ) {
                count
                sum {
                  timeViewedMinutes
                }
                dimensions {
                  uid
                }
              }
            }
          }
        }
      GRAPHQL

      @client.graphql(
        query,
        {
          accountTag: @account_id,
          uid: video_uid,
          dateStart: date_start.to_s,
          dateEnd: date_end.to_s,
        },
      )
    end

    # 複数動画の視聴統計を一括取得
    sig do
      params(
        date_start: Date,
        date_end: Date,
        limit: Integer,
        after_uid: T.nilable(String),
      ).returns(T::Hash[String, T.untyped])
    end
    def bulk_video_stats(date_start:, date_end:, limit: 100, after_uid: nil)
      filter = {
        date_geq: date_start.to_s,
        date_lt: date_end.to_s,
      }
      filter[:uid_gt] = after_uid if after_uid

      query = <<~GRAPHQL
        query($accountTag: String!, $filter: AccountVideoPlaybackEventsAdaptiveGroupsFilter!, $limit: Int!) {
          viewer {
            accounts(filter: { accountTag: $accountTag }) {
              videoPlaybackEventsAdaptiveGroups(
                filter: $filter
                orderBy: [uid_ASC]
                limit: $limit
              ) {
                count
                sum {
                  timeViewedMinutes
                }
                dimensions {
                  uid
                }
              }
            }
          }
        }
      GRAPHQL

      @client.graphql(
        query,
        {
          accountTag: @account_id,
          filter: filter,
          limit: limit,
        },
      )
    end

    # サーバーサイドメトリクス（課金に使用される配信分数）を取得
    # @note これは課金計算に使用される正確な配信分数
    sig do
      params(
        date_start: Date,
        date_end: Date,
        limit: Integer,
        after_uid: T.nilable(String),
      ).returns(T::Hash[String, T.untyped])
    end
    def server_side_minutes(date_start:, date_end:, limit: 100, after_uid: nil)
      filter = {
        date_geq: date_start.to_s,
        date_lt: date_end.to_s,
      }
      filter[:uid_gt] = after_uid if after_uid

      query = <<~GRAPHQL
        query($accountTag: String!, $filter: AccountStreamMinutesViewedAdaptiveGroupsFilter!, $limit: Int!) {
          viewer {
            accounts(filter: { accountTag: $accountTag }) {
              streamMinutesViewedAdaptiveGroups(
                filter: $filter
                orderBy: [uid_ASC]
                limit: $limit
              ) {
                sum {
                  minutesViewed
                }
                dimensions {
                  uid
                }
              }
            }
          }
        }
      GRAPHQL

      @client.graphql(
        query,
        {
          accountTag: @account_id,
          filter: filter,
          limit: limit,
        },
      )
    end

    # テナント別の配信使用量を集計
    # @param date_start [Date] 集計開始日
    # @param date_end [Date] 集計終了日
    # @return [Hash<String, Hash>] テナントID => { minutes_viewed:, video_count: }
    sig do
      params(
        date_start: Date,
        date_end: Date,
      ).returns(T::Hash[String, T::Hash[Symbol, T.untyped]])
    end
    def usage_by_tenant(date_start:, date_end:)
      # 全動画の使用量を取得
      all_video_stats = fetch_all_video_stats(date_start: date_start, date_end: date_end)

      # 動画UIDからテナントを特定して集計
      aggregate_by_tenant(all_video_stats)
    end

    private

    sig do
      params(
        date_start: Date,
        date_end: Date,
      ).returns(T::Array[T::Hash[String, T.untyped]])
    end
    def fetch_all_video_stats(date_start:, date_end:)
      all_stats = T.let([], T::Array[T::Hash[String, T.untyped]])
      after_uid = T.let(nil, T.nilable(String))

      loop do
        result = server_side_minutes(
          date_start: date_start,
          date_end: date_end,
          limit: 100,
          after_uid: after_uid,
        )

        groups = result.dig('data', 'viewer', 'accounts', 0, 'streamMinutesViewedAdaptiveGroups') || []
        break if groups.empty?

        all_stats.concat(groups)
        after_uid = groups.last&.dig('dimensions', 'uid')
        break if groups.size < 100
      end

      all_stats
    end

    sig do
      params(
        video_stats: T::Array[T::Hash[String, T.untyped]],
      ).returns(T::Hash[String, T::Hash[Symbol, T.untyped]])
    end
    def aggregate_by_tenant(video_stats)
      # 動画UIDからMediaAssetを取得してテナントを特定
      video_uids = video_stats.map { |s| s.dig('dimensions', 'uid') }.compact
      media_assets_by_cf_uid = MediaAsset
        .where("metadata->>'cloudflare_uid' IN (?)", video_uids)
        .index_by { |ma| ma.metadata['cloudflare_uid'] }

      result = T.let({}, T::Hash[String, T::Hash[Symbol, T.untyped]])

      video_stats.each do |stat|
        uid = stat.dig('dimensions', 'uid')
        minutes = stat.dig('sum', 'minutesViewed') || 0
        media_asset = media_assets_by_cf_uid[uid]

        next unless media_asset

        tenant_id = media_asset.tenant_id
        result[tenant_id] ||= { minutes_viewed: 0, video_count: 0 }
        result[tenant_id][:minutes_viewed] += minutes
        result[tenant_id][:video_count] += 1
      end

      result
    end
  end

  # 動画アップローダー（既存のMediaStorageと統合）
  class Uploader
    extend T::Sig

    sig { void }
    def initialize
      @client = T.let(Client.new, Client)
    end

    # 動画アップロード用URLを生成
    # @param tenant_id [String] テナントID（課金追跡用）
    # @param filename [String] ファイル名
    # @param file_size [Integer] ファイルサイズ（バイト）
    # @return [Hash] { upload_url:, video_uid: }
    sig do
      params(
        tenant_id: String,
        filename: String,
        file_size: Integer,
        max_duration_seconds: Integer,
      ).returns(T::Hash[Symbol, T.untyped])
    end
    def create_upload_url(tenant_id:, filename:, file_size:, max_duration_seconds: 3600)
      meta = {
        filename: filename,
        tenant_id: tenant_id,
        uploaded_at: Time.current.iso8601,
      }

      # 200MB以上はTUSプロトコルを使用
      if file_size > 200.megabytes
        result = @client.create_tus_upload_url(
          creator_id: tenant_id,
          upload_length: file_size,
          meta: meta,
        )
      else
        result = @client.create_direct_upload_url(
          creator_id: tenant_id,
          max_duration_seconds: max_duration_seconds,
          meta: meta,
        )
      end

      if result['success']
        {
          upload_url: result.dig('result', 'uploadURL'),
          video_uid: result.dig('result', 'uid'),
          success: true,
        }
      else
        {
          success: false,
          errors: result['errors'],
        }
      end
    end

    # アップロード完了後にMediaAssetを作成
    sig do
      params(
        tenant_id: String,
        cloudflare_uid: String,
        filename: String,
        file_size: Integer,
        duration_seconds: T.nilable(Float),
      ).returns(MediaAsset)
    end
    def create_media_asset(tenant_id:, cloudflare_uid:, filename:, file_size:, duration_seconds: nil)
      MediaAsset.create!(
        tenant_id: tenant_id,
        media_type: :video,
        mime_type: 'video/mp4', # Cloudflare Stream は MP4/HLS/DASH で配信
        metadata: {
          filename: filename,
          file_size: file_size,
          cloudflare_uid: cloudflare_uid,
          duration_seconds: duration_seconds,
          storage_type: 'cloudflare_stream',
          uploaded_at: Time.current.iso8601,
        },
      )
    end

    # Cloudflare Stream の埋め込みURLを取得
    sig { params(cloudflare_uid: String).returns(String) }
    def embed_url(cloudflare_uid)
      customer_subdomain = Settings.cloudflare.stream.customer_subdomain
      "https://customer-#{customer_subdomain}.cloudflarestream.com/#{cloudflare_uid}/manifest/video.m3u8"
    end

    # iframe埋め込み用URLを取得
    sig { params(cloudflare_uid: String).returns(String) }
    def iframe_url(cloudflare_uid)
      customer_subdomain = Settings.cloudflare.stream.customer_subdomain
      "https://customer-#{customer_subdomain}.cloudflarestream.com/#{cloudflare_uid}/iframe"
    end
  end

  # 課金計算サービス
  class BillingCalculator
    extend T::Sig

    # Cloudflare Stream の料金（2024年現在）
    STORAGE_PRICE_PER_1000_MINUTES = 5.0   # USD
    DELIVERY_PRICE_PER_1000_MINUTES = 1.0  # USD

    sig { void }
    def initialize
      @analytics = T.let(Analytics.new, Analytics)
      @client = T.let(Client.new, Client)
    end

    # テナント別の月間コストを計算
    sig do
      params(
        year: Integer,
        month: Integer,
      ).returns(T::Hash[String, T::Hash[Symbol, T.untyped]])
    end
    def monthly_cost_by_tenant(year:, month:)
      date_start = Date.new(year, month, 1)
      date_end = date_start.next_month

      # 配信使用量を取得
      delivery_usage = @analytics.usage_by_tenant(
        date_start: date_start,
        date_end: date_end,
      )

      # ストレージ使用量を計算（テナント別の動画の合計時間）
      storage_usage = calculate_storage_by_tenant

      # コストを計算
      result = T.let({}, T::Hash[String, T::Hash[Symbol, T.untyped]])

      all_tenant_ids = (delivery_usage.keys + storage_usage.keys).uniq

      all_tenant_ids.each do |tenant_id|
        delivery_minutes = delivery_usage.dig(tenant_id, :minutes_viewed) || 0
        storage_minutes = storage_usage[tenant_id] || 0

        delivery_cost = (delivery_minutes / 1000.0) * DELIVERY_PRICE_PER_1000_MINUTES
        storage_cost = (storage_minutes / 1000.0) * STORAGE_PRICE_PER_1000_MINUTES

        result[tenant_id] = {
          delivery_minutes: delivery_minutes,
          storage_minutes: storage_minutes,
          delivery_cost_usd: delivery_cost.round(2),
          storage_cost_usd: storage_cost.round(2),
          total_cost_usd: (delivery_cost + storage_cost).round(2),
          video_count: delivery_usage.dig(tenant_id, :video_count) || 0,
        }
      end

      result
    end

    private

    sig { returns(T::Hash[String, Float]) }
    def calculate_storage_by_tenant
      # Cloudflare Streamに保存されている動画の合計時間をテナント別に集計
      MediaAsset
        .videos
        .where("metadata->>'storage_type' = ?", 'cloudflare_stream')
        .group(:tenant_id)
        .sum("(metadata->>'duration_seconds')::float / 60.0")
        .transform_values(&:to_f)
    end
  end
end
