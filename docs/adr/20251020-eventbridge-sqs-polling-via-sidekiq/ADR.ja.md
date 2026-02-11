# ADR: EventBridge イベントの SQS ポーリングを Sidekiq 経由で処理する

- **日付**: 2025-10-20（2026-02-11 に遡及的に記録）
- **ステータス**: 確定
- **決定者**: Akira Suenami, Daichi Miyazaki

## コンテキスト

EventBridge から送信されるイベント（IdP のユーザー操作など）を Rails アプリケーションで受信・処理する必要がある。EventBridge のイベントは SQS キューに配信される構成になっており、アプリケーション側でこれをポーリングして処理するアーキテクチャを検討した。

ここで以下の選択肢が生じた:

1. **SQS クライアントライブラリで直接コンシューマを実装する** — SQS からメッセージを受信し、その場で処理する
2. **SQS からメッセージを受信し、Sidekiq ジョブとしてエンキューする** — ポーリング層と処理層を分離する

## 決定

**SQS ポーリング → Sidekiq エンキュー** の構成を採用する。

### アーキテクチャ

```
EventBridge → SQS Queue → [Eventbridge::PollService] → Sidekiq → [Eventbridge::ProcessWorker]
```

- `Eventbridge::PollService`（`bin/eventbridge_poller` で起動）が SQS キューを long polling する
- 受信したメッセージは JSON パースや validation を行わず、そのまま `Eventbridge::ProcessWorker.perform_async` に渡す
- `Eventbridge::ProcessWorker`（Sidekiq ジョブ）が実際のイベント解析・ディスパッチ・処理を担当する

### ポーリング層の設計方針

ポーリング層はできるだけ薄く軽くする。メッセージの中身には関知せず、Sidekiq にリレーすることだけに責務を限定する。

```ruby
# app/services/eventbridge/poll_service.rb
@poller.poll(wait_time_seconds: 20, visibility_timeout: 10, max_number_of_messages: 10) do |messages|
  messages.each do |message|
    Eventbridge::ProcessWorker.perform_async(message.body)
  end
end
```

### デプロイ構成

SQS ポーリングは専用の ECS サービス（`haguruma-main-service-eventbridge-poller-{env}`）として独立して動作する。Sidekiq の worker サービスとは別コンテナで動作し、リソース要件も軽量（cpu: 256, memory: 512）。

## 理由

### 非同期処理を Sidekiq に集約する

本アプリケーションでは Sidekiq を非同期処理の標準基盤として使用している。EventBridge イベント処理を Sidekiq に合流させることで:

- **リトライ機構**: Sidekiq の標準リトライ（指数バックオフ、Dead Job Queue）をそのまま利用できる
- **監視の一元化**: Sidekiq Web UI や既存の監視基盤でジョブの状態を確認できる
- **キューの優先度制御**: 既存のキュー優先度設定（`realtime_priority`, `high_priority`, `default`, `low_priority`）と統合できる
- **テナントコンテキスト管理**: `request_store-sidekiq` gem による自動クリアなど、Sidekiq 環境向けに整備された仕組みをそのまま利用できる

### SQS 直接コンシューマを不採用とした理由

SQS クライアントで直接処理する方がアーキテクチャとしてはシンプルだが:

- 独自のリトライ・エラーハンドリング機構を実装する必要がある
- 監視・可視化のために別途仕組みが必要になる
- テナントコンテキスト管理など、既存の Sidekiq 向けインフラと重複する仕組みを構築することになる

## 影響

- SQS ポーリング用の ECS サービスを別途運用する必要がある
- Sidekiq の worker サービスが停止していると、ポーリングしてもジョブが処理されない
- SQS → Sidekiq のリレーにより、メッセージの処理に若干のレイテンシが加わる（ただし非同期処理のため許容範囲内）

## 関連

- `app/services/eventbridge/poll_service.rb` — SQS ポーリングの実装
- `app/jobs/eventbridge/process_worker.rb` — Sidekiq ジョブとしてのイベント処理
- `bin/eventbridge_poller` — ポーリングプロセスの起動スクリプト
- `ecspresso/{stg,prod}/services/eventbridge_poller/` — ECS サービス定義
- [ADR: Sidekiq ジョブにおけるテナントコンテキスト管理の安全性](../20260209-tenant-context-management-in-sidekiq/ADR.ja.md) — 関連する後続の決定
