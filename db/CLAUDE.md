# DB設計方針

## 重要: Railsの規約に従う

- 主キーは `id` とする。
- 外部キーは `{model_name}_id` とする。
- ActiveRecordパターンが使われる。

## Eric Evans の DDD における Aggregate パターン

- 強い関連があるエンティティ（ActiveRecord継承クラス）は DDD の Aggregate を形成する

## 主キー
主キーの型について次のルールに従う。

- AggregateのルートエンティティはUUIDとする。
- Aggregateのローカルエンティティはint (or bigint) とする。

## マルチテナント分離
- ほぼすべてのテーブルに`tenant_id`を含む。
- 複合ユニーク制約によりテナント間のデータ分離を保証する。

### データ整合性
- 外部キー制約により参照整合性を保証
- `tenant_id`をはじめ、複合外部キーで積極的に用いる
