# ADR: seed-fu によるシードデータ管理の採用

- **日付**: 2025-11-19
- **ステータス**: 確定
- **決定者**: Akira Suenami, Thi Tram

## コンテキスト

### 背景

マスターデータやテストデータを管理する方法として、Rails 標準の `db/seeds.rb` には以下の課題がある:

1. **冪等性がない**: 何度も実行すると重複データが作成される
2. **単一ファイル**: 環境ごとの分離が難しい
3. **手続き的**: 宣言的なデータ定義ができない

### 要件

1. 何度実行しても同じ結果になる（冪等性）
2. 環境ごと（development/staging/production）に異なるデータを投入可能
3. データの追加・更新が容易

## 決定

**seed-fu gem を採用し、シードデータ管理を `db/fixtures/` ディレクトリに統一する。**

### 採用理由

1. **冪等性**: `seed` メソッドによる制約ベースのレコード管理で、何度実行しても重複しない
2. **環境分離**: `db/fixtures/{environment}/` で環境ごとのデータを管理可能
3. **宣言的**: 制約を指定した宣言的なデータ定義が可能

### ディレクトリ構造

```
db/fixtures/
  _shared/              # 全環境共通
    by_tenant/          # テナント別データ
      yokikotokiku/
        logo.svg
        key_visual.png
        theme.yml
  development/          # 開発環境のみ
  staging/              # ステージング環境のみ
  production/           # 本番環境のみ
```

### 移行計画

- `db/seeds/` は長期的に廃止
- 既存の `db/seeds/*.rb` は順次 `db/fixtures/` に移行

## 実装

### サービスクラスの使用原則

シードファイルでは、**ActiveRecord 継承クラスを直接使用することを避け、原則として `app/services/` 以下のサービスクラスを使用する**。

理由:
1. **本番と同じプロセスでデータが投入される**: サービスクラスを経由することで、バリデーション、コールバック、関連データの作成など、本番環境と同じロジックでデータが投入される
2. **データ不整合の防止**: サービスクラスに冪等性の担保ロジックを実装することで、シードの再実行時も安全
3. **テスト容易性**: サービスクラスは単体テストが書きやすい

```ruby
# 推奨: サービスクラスを使用
result = AdminArea::Contents::SaveEntryService.new(
  content_type: content_type,
  content_entry: nil,
  fields_params: { 'title' => 'サンプル記事' },
).call

# 非推奨: ActiveRecord を直接使用
ContentEntry.create!(title: 'サンプル記事', ...)
```

ただし、以下の場合はActiveRecordの直接使用を許容する:
- 単純なマスターデータの投入（`Country.seed(:code, ...)` など）
- サービスクラスが存在しない純粋なマスターデータモデル
- 複雑なビジネスロジックを持たないデータ

### 基本的な使い方

```ruby
# db/fixtures/01_countries.rb
Country.seed(:code,
  { code: 'JP', name: '日本' },
  { code: 'US', name: 'アメリカ' },
)
```

### 実行コマンド

```bash
# 全環境共通 + 現在の環境のフィクスチャを実行
rails db:seed_fu

# 特定のパスを指定
rails db:seed_fu FIXTURE_PATH=db/fixtures/_shared
```

## 影響

### Positive

- シードデータの冪等な管理が可能
- 環境ごとのデータ分離が容易
- テナント別のデータ管理が整理される

### Negative

- Rails 標準の `db/seeds.rb` との混在期間が発生
- 既存データの移行作業が必要

## 関連

### seed-fu の開発経緯

seed-fu は 2008 年に [Mobomo によって開発](https://www.mobomo.com/2008/04/seed-fu-simple-seed-data-for-rails/)された。

`db/fixtures/` という命名は、seed-fu が参考にした `db-populate` プラグインから継承されている。Rails の `db/seeds.rb` は Rails 2.3.4（2009年）で追加されたため、seed-fu/db-populate の方が先行して存在していた。

つまり、seed-fu が `db/seeds` ではなく `db/fixtures` を使う理由は「Rails の seeds より前から存在していた」という歴史的経緯による。

### 関連リンク

- [GitHub - mbleigh/seed-fu](https://github.com/mbleigh/seed-fu)
- [Seed Fu: Simple Seed Data for Rails (2008)](https://www.mobomo.com/2008/04/seed-fu-simple-seed-data-for-rails/)

---

*注: この ADR は 2025/12/29 に作成されたが、決定自体は 2025/11/19 に行われていたため、日付を遡って記録している。*
