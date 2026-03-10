# typed: false
# frozen_string_literal: true

module CloudflareStream
  # S3にアップロード済みの動画をCloudflare Streamに非同期で転送するJob
  #
  # 使用例:
  #   CloudflareStream::SyncVideoJob.perform_later(media_asset.id)
  #
  # リトライ戦略:
  #   - 最大5回リトライ
  #   - 指数バックオフ（10秒、30秒、90秒、270秒、810秒）
  #   - 全リトライ失敗後は cloudflare_sync_status を 'failed' に設定
  #
  class SyncVideoJob < ApplicationJob
    queue_as :cloudflare_sync

    # 指数バックオフでリトライ
    retry_on StandardError, wait: :polynomially_longer, attempts: 5 do |job, error|
      # 全リトライ失敗時の処理
      media_asset = MediaAsset.find_by(id: job.arguments.first)
      if media_asset
        media_asset.update!(
          metadata: media_asset.metadata.merge(
            'cloudflare_sync_status' => CloudflareStream::SyncStatus::FAILED,
            'cloudflare_sync_error' => error.message,
            'cloudflare_sync_failed_at' => Time.current.iso8601,
          ),
        )
        Rails.logger.error(
          "[CloudflareStream::SyncVideoJob] Failed after all retries. " \
          "media_asset_id=#{media_asset.id}, error=#{error.message}",
        )
      end
    end

    # 一時的なネットワークエラーはリトライ
    retry_on Faraday::ConnectionFailed, wait: 30.seconds, attempts: 5
    retry_on Faraday::TimeoutError, wait: 30.seconds, attempts: 5

    def perform(media_asset_id)
      media_asset = MediaAsset.find(media_asset_id)

      # 動画以外はスキップ
      unless media_asset.video?
        Rails.logger.info("[CloudflareStream::SyncVideoJob] Skipping non-video asset: #{media_asset_id}")
        return
      end

      # 既に同期済みならスキップ
      if media_asset.metadata['cloudflare_sync_status'] == CloudflareStream::SyncStatus::COMPLETED
        Rails.logger.info("[CloudflareStream::SyncVideoJob] Already synced: #{media_asset_id}")
        return
      end

      # ステータスを処理中に更新
      update_sync_status(media_asset, CloudflareStream::SyncStatus::PROCESSING)

      # Cloudflare Streamに転送
      uploader = CloudflareStream::Uploader.new
      result = uploader.sync_to_cloudflare(media_asset)

      if result[:success]
        # 成功: ステータスとcloudflare_uidを保存
        media_asset.update!(
          metadata: media_asset.metadata.merge(
            'cloudflare_sync_status' => CloudflareStream::SyncStatus::COMPLETED,
            'cloudflare_uid' => result[:cloudflare_uid],
            'cloudflare_synced_at' => Time.current.iso8601,
          ),
        )
        Rails.logger.info(
          "[CloudflareStream::SyncVideoJob] Successfully synced. " \
          "media_asset_id=#{media_asset_id}, cloudflare_uid=#{result[:cloudflare_uid]}",
        )
      else
        # 失敗: エラーを記録してリトライ
        error_message = result[:errors]&.map { |e| e['message'] }&.join(', ') || 'Unknown error'
        raise CloudflareSyncError, "Failed to sync to Cloudflare: #{error_message}"
      end
    end

    private

    def update_sync_status(media_asset, status)
      media_asset.update!(
        metadata: media_asset.metadata.merge(
          'cloudflare_sync_status' => status,
          'cloudflare_sync_updated_at' => Time.current.iso8601,
        ),
      )
    end
  end

  # Cloudflare同期エラー
  class CloudflareSyncError < StandardError; end
end
