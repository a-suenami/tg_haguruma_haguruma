# マルチテナント分離 - 残課題

## 完了した作業

- `Multitenancy` concern を作成 (`app/models/concerns/multitenancy.rb`)
- 以下のモデルに `include Multitenancy` を適用:
  - Admin
  - User
  - ContentType
  - ContentEntry
  - MediaAsset
  - Admin::Auth0Account
  - ContentType::Field
  - ContentEntry::Field
  - ContentEntry::Version

## 未解決の問題

### 1. API エリア: `Tenant.current_id` が未設定 (重大)

**ファイル:** `app/controllers/api/v1/auth/application_controller.rb:16-21`

```ruby
def set_user_oauth_provider
  @user_oauth_provider = T.let(
    Tenant.current&.oauth_provider,  # ← Tenant.current は常に nil
    T.nilable(OauthProvider),
  )
end
```

**問題:**
- API エリアでは `Tenant.current_id` がどこにも設定されていない
- そのため `Tenant.current` は常に `nil` を返す
- 結果として `@user_oauth_provider` も `nil` になり、API 認証が機能しない

**修正案:**
- API リクエストからテナント ID を取得する仕組みが必要
- 選択肢:
  1. サブドメインから取得
  2. リクエストヘッダーから取得 (例: `X-Tenant-ID`)
  3. パスパラメータから取得 (例: `/api/v1/:tenant_id/auth/...`)

### 2. AdminArea: `set_tenant` で `Tenant.current_id=` を使用するよう統一

**ファイル:** `app/controllers/admin_area/application_controller.rb:46`

```ruby
# 現在の実装
RequestStore.store[:current_tenant] = tenant_id.to_sym

# 推奨される実装
Tenant.current_id = tenant_id
```

**問題:**
- `RequestStore.store[:current_tenant]` を直接設定している
- `Tenant.current_id=` setter を使用すべき（一貫性のため）
- `to_sym` を使用しているが、`Tenant.current_id` は `.to_s` を期待している

### 3. RulerArea: `set_tenant` がデフォルトで呼ばれていない

**ファイル:** `app/controllers/ruler_area/application_controller.rb`

**問題:**
- `set_tenant` メソッドは存在するが、`before_action` として登録されていない
- 各子コントローラーで明示的に呼び出す必要がある
- 新しいコントローラーを追加する際に忘れるリスクがある

**修正案:**
- `before_action :set_tenant` を親コントローラーに追加
- または、テナントスコープが不要なアクションでは `skip_before_action` を使用

## 確認済みの正常動作

- AdminArea のログイン時のテナント検証は正しく機能している
- データベースレベルの制約（外部キー、複合インデックス）は適切
- `Multitenancy` concern による `default_scope` が全モデルに適用済み
