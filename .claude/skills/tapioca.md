# Tapioca チェックリスト

このプロジェクトでは Sorbet + Tapioca を使用しています。以下の変更を行った場合は、対応する tapioca コマンドを実行してください。

## 実行が必要なケース

### `tapioca gem` を実行

新しい gem を追加した場合（Gemfile を変更して bundle install した後）:

```bash
source env.sh && bundle exec tapioca gem
```

### `tapioca dsl` を実行

以下のいずれかを変更した場合:

- **モデル**: `app/models/` 配下のファイルを追加・変更
- **ルート**: `config/routes/` 配下のファイルを変更
- **DBスキーマ**: `db/schemas/` 配下のファイルを追加・変更

```bash
source env.sh && bundle exec tapioca dsl
```

特定のモデルのみ再生成する場合:

```bash
source env.sh && bundle exec tapioca dsl ModelName
```

## コミット前チェック

1. `bundle exec srb tc .` で型チェックが通ることを確認
2. 新しい RBI ファイルが生成されていたらコミットに含める
   - `sorbet/rbi/gems/` - gem の RBI
   - `sorbet/rbi/dsl/` - DSL の RBI
