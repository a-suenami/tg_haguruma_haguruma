# ADR: Sidekiq ジョブにおけるテナントコンテキスト管理の安全性

- **日付**: 2026-02-09
- **ステータス**: 確定
- **決定者**: Akira Suenami

## コンテキスト

EventBridge イベント処理（`IdpProcessor`）では、イベントの `source` から `tenant_id` を抽出し、`Tenant.current_id` を設定してから各 Handler を呼び出す必要がある。

`Tenant.current_id` は内部的に `RequestStore.store[:current_tenant]` に値を保存しており、`Multitenancy` concern の `default_scope` がこの値を参照してマルチテナントのスコープを実現している。

```ruby
# Multitenancy concern
def default_scope
  where(tenant_id: RequestStore.store[:current_tenant]) if RequestStore.store[:current_tenant].present?
end
```

ここで以下の疑問が生じた:

1. `RequestStore` は Sidekiq のスレッドプール環境でスレッドセーフか？
2. テナントコンテキストの save/restore パターンは安全か？
3. ensure ブロックと early return の組み合わせに落とし穴はないか？

## 決定

`RequestStore` + save/restore パターンを採用する。

### RequestStore のスレッド安全性

`RequestStore` は `Thread.current` ベースのスレッドローカルストレージである。スレッドごとに独立した領域を持つため、異なるスレッド間でデータが干渉することはない。

Sidekiq はスレッドプールモデルで動作し、1 スレッドにつき 1 ジョブを逐次実行する。同一スレッドで同時に 2 つのジョブが走ることはない。

さらに `request_store-sidekiq` gem が Sidekiq のミドルウェアとして組み込まれており、ジョブの実行前後で `RequestStore` を自動的にクリアする。これにより、前のジョブのテナントコンテキストが次のジョブにリークすることはない。

### save/restore パターン

Sidekiq ジョブとして呼ばれる場合、`request_store-sidekiq` がジョブ開始時にクリアするため `previous_tenant_id` はほぼ常に `nil` になる。save/restore パターンは「万が一すでにテナントが設定されているコンテキストから呼ばれた場合」（テストやネストした呼び出し等）に備えた防御的なコーディングである。

```ruby
def process(message)
  # ...
  previous_tenant_id = Tenant.current_id
  begin
    Tenant.current_id = @tenant_id
    dispatch(message.detail_type, detail)
  ensure
    if previous_tenant_id
      Tenant.current_id = previous_tenant_id
    else
      RequestStore.store.delete(:current_tenant)
    end
  end
end
```

ensure での復帰時、`previous_tenant_id` が `nil`（テナント未設定状態）の場合は `Tenant.current_id = nil` ではなく `RequestStore.store.delete(:current_tenant)` で明示的にクリアする。`Tenant.current_id = nil` は内部で `nil.to_s → ""` となり空文字列が残るため。

### ensure ブロックと early return の注意点

ensure ブロックは、メソッド内で early return が発生した場合にも実行される。`previous_tenant_id` の代入は ensure で保護される `begin` ブロックの直前に配置し、代入前の early return では ensure が意図しない副作用を起こさないようにする。

```ruby
# NG: early return 時に previous_tenant_id が nil のまま ensure に入り、テナントが消える
def process(message)
  return unless detail.is_a?(Hash)          # ← ここで return すると...
  previous_tenant_id = Tenant.current_id    # ← これが実行されないまま
  Tenant.current_id = @tenant_id
  # ...
ensure
  RequestStore.store.delete(:current_tenant) if previous_tenant_id.nil?  # ← ensure は実行される
end

# OK: begin...ensure を guard 節の後に配置
def process(message)
  return unless detail.is_a?(Hash)
  previous_tenant_id = Tenant.current_id
  begin
    Tenant.current_id = @tenant_id
    # ...
  ensure
    # previous_tenant_id は必ず代入済み
  end
end
```

## 理由

### RequestStore を採用した理由

- Rails の既存パターン（`Multitenancy` concern）が `RequestStore` を前提としており、新たな仕組みを導入するよりも一貫性が高い
- `request_store-sidekiq` gem により Sidekiq 環境でも安全に動作することが保証されている
- スレッドローカルストレージであるため、ロック不要でパフォーマンスへの影響がない

### save/restore パターンを採用した理由

- テスト時や将来的なネスト呼び出しで、呼び出し元のテナントコンテキストを破壊しない
- Sidekiq 単体で使う限りは `request_store-sidekiq` がクリアするため冗長だが、防御的な設計としてコストが低い

### begin...ensure の分離を採用した理由

- メソッドレベルの ensure だと、guard 節での early return 時に未初期化の `previous_tenant_id` が `nil` として扱われ、意図しないテナントコンテキストの削除が発生する
- `begin...ensure...end` で保護範囲を明示することで、テナント操作の開始と終了が対になることを構造的に保証する

## 影響

- `RequestStore`（`Thread.current`）に依存しているため、Ractor など異なる並行モデルではそのまま使えない
- 同パターンを他の Processor で使う場合は、同じ `begin...ensure` 構造を踏襲する必要がある

## 関連

- `app/services/eventbridge/processors/idp_processor.rb` — 本パターンの実装箇所
- `app/models/concerns/multitenancy.rb` — `default_scope` でのテナントスコープ
- `app/models/tenant.rb` — `Tenant.current_id` / `Tenant.current_id=` の定義
