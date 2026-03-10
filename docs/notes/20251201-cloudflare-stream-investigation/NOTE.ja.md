# Cloudflare Stream 動画配信調査レポート

## 概要

media_assets テーブルの動画コンテンツを CloudFront ではなく Cloudflare Stream で配信することの技術的妥当性を調査しました。

## 調査結果サマリー

**結論: 技術的に妥当であり、テナント別の課金追跡が可能**

### Cloudflare Stream の特徴

| 項目 | 内容 |
|------|------|
| ストレージ料金 | $5/1,000分（動画時間ベース、ファイルサイズ無関係） |
| 配信料金 | $1/1,000分（配信された分数ベース） |
| エンコーディング | 自動（アップロードされた動画を自動でHLS/DASHに変換） |
| CDN | 自動（グローバルCDN配信） |

### テナント別課金の実現方法

Cloudflare Stream には **`creator` フィールド** があり、これを使ってテナントIDを紐付けることが可能です：

1. **アップロード時**: `creator` フィールドに `tenant_id` を設定
2. **分析時**: GraphQL Analytics API で動画UID別の使用量を取得
3. **集計**: 動画UID → MediaAsset → tenant_id のマッピングで集計

### 利用可能なメトリクス

#### クライアントサイドメトリクス (`videoPlaybackEventsAdaptiveGroups`)
- `count`: 視聴回数
- `timeViewedMinutes`: 視聴分数
- **制限**: Stream Player 使用時のみ有効

#### サーバーサイドメトリクス (`streamMinutesViewedAdaptiveGroups`)
- `minutesViewed`: 配信分数（**課金に使用される値**）
- **特徴**: HLS/DASH経由の配信すべてをカウント（プレーヤー種別不問）

## アーキテクチャ提案

### 非同期アップロードフロー

S3を信頼のソースとして、Cloudflareへは非同期で転送する設計です。
これにより、Cloudflareへのアップロード失敗時もデータ不整合が発生しません。

```
┌──────────────────────────────────────────────────────────────────┐
│                     アップロードフロー                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. クライアント                                                  │
│     │                                                            │
│     ▼                                                            │
│  2. S3にアップロード（既存フロー）                                 │
│     │                                                            │
│     ▼                                                            │
│  3. MediaAsset作成                                               │
│     metadata: { cloudflare_sync_status: 'pending' }              │
│     │                                                            │
│     ▼                                                            │
│  4. SyncVideoJob をエンキュー ─────────────────┐                 │
│     │                                         │                 │
│     ▼                                         ▼                 │
│  5. レスポンス返却（即座）              6. Sidekiq Worker         │
│     ※この時点では CloudFront で配信        │                     │
│                                             ▼                    │
│                                       7. S3から署名付きURL生成    │
│                                             │                    │
│                                             ▼                    │
│                                       8. Cloudflare Stream API   │
│                                          (copy from URL)         │
│                                             │                    │
│                                     ┌───────┴───────┐            │
│                                     ▼               ▼            │
│                                  成功            失敗            │
│                                     │               │            │
│                                     ▼               ▼            │
│                              status:         リトライ (最大5回)   │
│                              'completed'           │            │
│                              cloudflare_uid        ▼            │
│                              保存            status: 'failed'    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 再生時のフォールバック

```
┌──────────────────────────────────────────────────────────────────┐
│                       動画再生フロー                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  CloudflareStream::Uploader#playback_url(media_asset)            │
│     │                                                            │
│     ▼                                                            │
│  cloudflare_uid あり?                                            │
│     │                                                            │
│     ├─── Yes ──▶ Cloudflare Stream HLS URL                      │
│     │           (テナント別課金対象)                              │
│     │                                                            │
│     └─── No ───▶ CloudFront 署名付きURL                         │
│                 (同期完了まで or 同期失敗時のフォールバック)       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### システム構成図

```
┌──────────────────────────────────────────────────────────────────┐
│                         バックエンド                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────┐    ┌──────────────────────────────┐    │
│  │ MediaAsset::         │    │ MediaAsset                   │    │
│  │ Uploader            │───▶│ metadata:                    │    │
│  │ (S3アップロード)     │    │   - cloudflare_sync_status   │    │
│  └─────────────────────┘    │   - cloudflare_uid           │    │
│           │                 └──────────────────────────────┘    │
│           │ 動画の場合                                          │
│           ▼                                                      │
│  ┌─────────────────────┐                                        │
│  │ CloudflareStream::  │                                        │
│  │ SyncVideoJob        │──── S3 → Cloudflare Stream             │
│  │ (Sidekiq)           │     (リトライ可能)                      │
│  └─────────────────────┘                                        │
│                                                                  │
│  ┌─────────────────────┐    ┌──────────────────────────────┐    │
│  │ CloudflareStream::  │───▶│ 月次課金レポート             │    │
│  │ BillingCalculator   │    │ (テナント別コスト集計)       │    │
│  └─────────────────────┘    └──────────────────────────────┘    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## サンプル実装

### 1. 動画アップロードフロー（既存フローを拡張）

既存の `MediaAsset::Uploader#upload` を使用するだけで、自動的に Cloudflare 同期がエンキューされます。

```ruby
# 既存のアップロード処理（変更不要）
uploader = MediaAsset::Uploader.new
result = uploader.upload(file: uploaded_file, tenant_id: current_tenant.id)

# 返却される MediaAsset には以下の metadata が含まれる:
# - s3_object_path: S3上のパス
# - cloudflare_sync_status: 'pending' (動画の場合)
#
# バックグラウンドで CloudflareStream::SyncVideoJob が実行され、
# 成功すると cloudflare_uid が設定される
```

### 2. 同期ステータスの確認

```ruby
media_asset = MediaAsset.find(id)

case media_asset.metadata['cloudflare_sync_status']
when CloudflareStream::SyncStatus::PENDING
  # まだ同期開始前
when CloudflareStream::SyncStatus::PROCESSING
  # 同期処理中
when CloudflareStream::SyncStatus::COMPLETED
  # 同期完了 - Cloudflare Stream から配信可能
  cloudflare_uid = media_asset.metadata['cloudflare_uid']
when CloudflareStream::SyncStatus::FAILED
  # 同期失敗 - CloudFront からのフォールバック配信
  error = media_asset.metadata['cloudflare_sync_error']
end
```

### 3. 動画再生URL取得（フォールバック付き）

```ruby
uploader = CloudflareStream::Uploader.new
playback_url = uploader.playback_url(media_asset)

# cloudflare_uid があれば Cloudflare Stream HLS URL
# なければ CloudFront 署名付きURL（フォールバック）
```

### 4. 手動リトライ

```ruby
# 失敗した同期を手動でリトライ
media_asset = MediaAsset.find(id)
if media_asset.metadata['cloudflare_sync_status'] == CloudflareStream::SyncStatus::FAILED
  # ステータスをリセットしてジョブを再エンキュー
  media_asset.update!(
    metadata: media_asset.metadata.merge(
      'cloudflare_sync_status' => CloudflareStream::SyncStatus::PENDING,
    ),
  )
  CloudflareStream::SyncVideoJob.perform_later(media_asset.id)
end
```

### 5. テナント別課金レポート生成

```ruby
# 月次課金レポートJob
class MonthlyBillingReportJob < ApplicationJob
  def perform(year, month)
    calculator = CloudflareStream::BillingCalculator.new
    costs = calculator.monthly_cost_by_tenant(year: year, month: month)

    costs.each do |tenant_id, data|
      BillingReport.create!(
        tenant_id: tenant_id,
        year: year,
        month: month,
        video_delivery_minutes: data[:delivery_minutes],
        video_storage_minutes: data[:storage_minutes],
        delivery_cost_usd: data[:delivery_cost_usd],
        storage_cost_usd: data[:storage_cost_usd],
        total_cost_usd: data[:total_cost_usd],
      )
    end
  end
end
```

### 3. 動画再生URL取得

```ruby
# 動画再生URL取得
class VideoPlaybackService
  def initialize(media_asset)
    @media_asset = media_asset
    @uploader = CloudflareStream::Uploader.new
  end

  def playback_url
    cloudflare_uid = @media_asset.metadata['cloudflare_uid']
    return nil unless cloudflare_uid

    @uploader.embed_url(cloudflare_uid)
  end

  def iframe_url
    cloudflare_uid = @media_asset.metadata['cloudflare_uid']
    return nil unless cloudflare_uid

    @uploader.iframe_url(cloudflare_uid)
  end
end
```

## 環境変数

以下の環境変数を設定する必要があります：

```bash
# Cloudflare Stream
CLOUDFLARE_STREAM_ACCOUNT_ID=your_account_id
CLOUDFLARE_STREAM_API_TOKEN=your_api_token  # Account Analytics 権限が必要
CLOUDFLARE_STREAM_CUSTOMER_SUBDOMAIN=your_subdomain  # 例: a1b2c3d4
```

## 既存システムとの共存

### 画像は引き続きCloudFront

```ruby
# MediaAsset::Uploader を拡張
class MediaAsset::Uploader
  def upload(file:, tenant_id:)
    media_type = MediaAsset.detect_media_type(file.content_type)

    case media_type
    when :video
      # Cloudflare Stream 経由
      upload_video_to_cloudflare(file, tenant_id)
    else
      # 従来通りS3 + CloudFront
      upload_to_s3(file, tenant_id)
    end
  end
end
```

## 考慮事項

### メリット

1. **テナント別課金が可能**: `creator` フィールドでテナント追跡
2. **動画別の使用量追跡**: GraphQL API で詳細な分析が可能
3. **自動エンコーディング**: アップロードするだけでHLS/DASH配信
4. **シンプルな料金体系**: ストレージ + 配信の2軸のみ
5. **帯域幅の心配なし**: 配信は分数ベースの課金

### デメリット・注意点

1. **Ruby gemがない**: 直接HTTPリクエストでAPIを呼ぶ必要あり（サンプル実装済み）
2. **GraphQL APIの制限**: 1クエリで取得できる期間は1ヶ月まで
3. **クライアントサイドメトリクスの制限**: Stream Player以外では視聴回数が取れない
4. **移行コスト**: 既存の動画をCloudflare Streamに再アップロードが必要

### 推奨事項

1. **新規アップロードのみCloudflare Stream**: 既存動画は当面CloudFrontのまま
2. **月次バッチで課金計算**: リアルタイム性は不要なので、月次Jobで集計
3. **サーバーサイドメトリクス使用**: 課金にはサーバーサイドの配信分数を使用

## 参考リンク

- [Cloudflare Stream Pricing](https://developers.cloudflare.com/stream/pricing/)
- [GraphQL Analytics API](https://developers.cloudflare.com/stream/getting-analytics/fetching-bulk-analytics/)
- [Manage creators](https://developers.cloudflare.com/stream/manage-video-library/creator-id/)
- [Direct creator uploads](https://developers.cloudflare.com/stream/uploading-videos/direct-creator-uploads/)

## 次のステップ

1. [ ] Cloudflare アカウントでStream機能を有効化
2. [ ] API トークンを生成（Account Analytics 権限）
3. [ ] サンプル動画でアップロード/配信テスト
4. [ ] GraphQL API で使用量取得テスト
5. [ ] 本番環境への段階的導入計画策定
