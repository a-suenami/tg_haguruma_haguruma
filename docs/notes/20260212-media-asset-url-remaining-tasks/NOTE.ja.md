# MediaAsset URL: 残タスク

## 背景

MR !232 にて `resolved_url` 導入・`purpose` 廃止・コード簡素化を実施した。
本ノートは未実施の残タスクをまとめる。

## 1. データマイグレーション

既存の MediaAsset は `s3_object_path` に `private/` プレフィックスがなく、`public_s3_object_path` も NULL のままである。`resolved_url` のフォールバック（署名付き URL）により表示は維持されるが、公開コンテンツのアセットは `public/` にコピーすべきである。

### Task 1: `media_assets:prefix_private`

既存アセットの `s3_object_path` に `private/` プレフィックスを付与。

- `s3_object_path` が `private/` で始まらないレコードを対象
- S3 上でオブジェクトを `{old}` → `private/{old}` にコピー
- DB の `s3_object_path` を更新
- 元ファイルは削除しない（動作確認後に手動削除）

### Task 2: `media_assets:sync_public_copies`

公開コンテンツの MediaAsset を `public/` にコピー。

- 全テナントの `published` + `visibility_public` な Version を取得
- 既存の `VisibilitySyncService` をそのまま利用（media_asset フィールド + richtext 内の mediaAssetId 両方対応済み）
- `CopyService#copy_to_public` は冪等（既に public copy があればスキップ）

### 実行順序

```bash
source env.sh && bundle exec rails media_assets:prefix_private
# 動作確認
source env.sh && bundle exec rails media_assets:sync_public_copies
```

Task 2 は Task 1 完了後に実行（`private/` パスがないと S3 copy の source が見つからないため）。

## 2. S3 公開コピーの非同期化

コンテンツ公開時の `VisibilitySyncService`（private → public への S3 コピー）は現在同期的に実行されている。コンテンツに含まれる MediaAsset の数が多い場合、公開操作のレスポンスタイムに影響する。

`resolved_url` のフォールバック（署名付き URL）により、コピー完了前でも画像は表示されるため、Active Job 経由の非同期実行に安全に移行できる。

### 対象ファイル

- `app/services/admin_area/contents/publish_entry_service.rb`（呼び出し元）
- `app/services/media_assets/visibility_sync_service.rb`（実処理）

## 関連

- MR: https://git.l.twogate.net/haguruma/haguruma/-/merge_requests/232
- 元プラン: `docs/plans/20260211-fix-media-asset-url-resolution.md`
