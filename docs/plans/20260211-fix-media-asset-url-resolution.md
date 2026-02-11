# MediaAsset URL 生成ロジック修正 + データマイグレーション

## Context

MediaAsset を `private/` と `public/` に振り分ける機能をデプロイしたところ、画像が表示されなくなる障害が発生。原因は、URL 生成の判断ロジックが「MediaAsset 自身の公開状態」ではなく「呼び出し側での content entry の visibility チェック」に実装されていたこと。既存の公開済みコンテンツは `public_s3_object_path` が NULL のため `public_url` が `nil` を返す。

## Part 1: `resolved_url` 導入とコード簡素化

### Step 1: `MediaAsset#resolved_url` 追加

**`app/models/media_asset.rb`**

```ruby
def resolved_url
  if public_copy?
    public_url
  else
    url(purpose: :public)
  end
end
```

`public_s3_object_path` があれば署名なし URL、なければ署名付き URL にフォールバック。既存データも即座に復旧する。

### Step 2: `ContentFieldHelper` 簡素化

**`app/helpers/user_area/content_field_helper.rb`**

- `media_asset_url(field:, public:)` → `media_asset_url(field:)` に変更、内部で `media_asset.resolved_url` を呼ぶ
- `render_richtext_field(field:, public:)` → `render_richtext_field(field:)` に変更

### Step 3: `RichtextUrlTransformer` 簡素化

**`app/services/richtext_url_transformer.rb`** (`typed: strict`)

全メソッドから `public:` パラメータを除去。`get_media_asset_url_by_id` で `media_asset.resolved_url` を呼ぶ。

### Step 4: `RootController` 簡素化

**`app/controllers/user_area/alpha/root_controller.rb`**

`load_kv_image_url` の `if version.visibility == 'public'` 分岐を削除、`resolved_url` 一行に。

### Step 5: `ContentEntrySerializer` 修正

**`app/serializers/content_entry_serializer.rb`**

- `media_asset_hash`: `Uploader` 直接利用を `field_media_asset.media_asset.resolved_url` に置換
- richtext 行: `RichtextUrlTransformer.transform` から `public:` 引数を除去
- `attribute_value` から未使用になる `version` パラメータを除去

### Step 6: ERB テンプレート更新（10ファイル）

以下のファイルから `public: version.visibility == 'public'` を除去:

| ファイル | 変更箇所 |
|---|---|
| `views/user_area/alpha/root/index.html.erb` | `media_asset_url` |
| `views/user_area/alpha/blog/_blog_item.html.erb` | `media_asset_url` |
| `views/user_area/alpha/blog/show.html.erb` | `media_asset_url` + `render_richtext_field` |
| `views/user_area/alpha/tickets/_ticket_item.html.erb` | `media_asset_url` |
| `views/user_area/alpha/tickets/show.html.erb` | `render_richtext_field` |
| `views/user_area/alpha/schedules/_schedule_item.html.erb` | `media_asset_url` |
| `views/user_area/alpha/schedules/show.html.erb` | `render_richtext_field` |
| `views/user_area/alpha/news/show.html.erb` | `render_richtext_field` |
| `views/user_area/alpha/privileges/show.html.erb` | `render_richtext_field` |
| `views/user_area/alpha/biographies/show.html.erb` | `render_richtext_field` |

### Step 7: dead code 削除

**`app/services/media_assets/copy_service.rb`**

`delete_public_copy` メソッドを削除（どこからも呼ばれていない）。

### Step 8: lint & 型チェック

```bash
source env.sh && rubocop -A
source env.sh && srb tc .
```

---

## Part 2: データマイグレーション rake タスク

**`lib/tasks/migrate_media_assets_storage.rake`** (新規作成)

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

---

## 検証方法

1. `rubocop -A` と `srb tc .` が通ること
2. rake タスク実行後、DB の `s3_object_path` が全て `private/` で始まること
3. 公開コンテンツの MediaAsset に `public_s3_object_path` がセットされていること
4. ユーザー画面で画像が表示されること（公開コンテンツ = 署名なし URL、制限コンテンツ = 署名付き URL）
5. API レスポンスの画像 URL が正しいこと

---

## 今後の改善: S3 公開コピーの非同期化

コンテンツ公開時の `VisibilitySyncService`（private → public への S3 コピー）は現在同期的に実行されている。コンテンツに含まれる MediaAsset の数が多い場合、公開操作のレスポンスタイムに影響する。

`resolved_url` のフォールバック（署名付き URL）により、コピー完了前でも画像は表示されるため、Active Job 経由の非同期実行に安全に移行できる。

### 対象ファイル

- `app/services/admin_area/contents/publish_entry_service.rb`（呼び出し元）
- `app/services/media_assets/visibility_sync_service.rb`（実処理）
