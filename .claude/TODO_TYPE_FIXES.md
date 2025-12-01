# 型エラー修正 TODO

## 修正済み ✅

以下のファイルは `# typed: true` に復元済み:

| ファイル | 修正内容 |
|---------|---------|
| `app/controllers/admin_area/contents/collection/entries/edit_controller.rb` | `attr_reader :field_values` が追加済みで問題なし |
| `app/controllers/admin_area/contents/collection/entries/show_controller.rb` | 同上 |
| `app/controllers/api/v1/contents_controller.rb` | `.new` を明示的に呼び出すように修正 |
| `app/queries/application_query.rb` | `T.unsafe` でラップして splat 問題を回避 |
| `app/queries/user_queries/content_entries_query.rb` | `by_content_type` をインスタンスメソッドに変更 |
| `app/serializers/content_entry_serializer.rb` | `s3_object_path` を `media_assets` カラムに追加済み |
| `app/models/content_entry/field_media_asset.rb` | `delegate :s3_object_path, to: :media_asset` で解決 |
| `app/lib/media_storage.rb` | `app/models/media_asset/` に移動・削除 |

## 残り（対応不要）

| ファイル | 理由 |
|---------|------|
| `app/controllers/concerns/ruler_area/tenant_settable.rb` | concern では `params` が認識されないため `# typed: false` のまま維持 |

## スキーマ関連 TODO

### `content_types` テーブル

データマイグレーション後に以下を有効化:

1. `db/schemas/content_types.schema` のユニークインデックスをアンコメント:
   ```ruby
   add_index :content_types, [:tenant_id, :unique_name], unique: true
   ```

2. `app/models/content_type.rb` の `rubocop:disable` コメントを削除

3. カラムに `null: false` 制約を追加:
   ```ruby
   t.text :display_name, null: false, default: ''
   t.text :unique_name, null: false, default: ''
   t.text :description, null: false, default: ''
   ```

## 実行コマンド

```bash
# 型チェック
source env.sh && bundle exec srb tc

# RuboCop
source env.sh && bundle exec rubocop

# Tapioca DSL更新（スキーマ変更後）
source env.sh && bundle exec tapioca dsl
```
