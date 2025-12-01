# マルチテナント分離 - 進捗

## 完了した作業

### Phase 1: Multitenancy Concern の適用
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

### Phase 2: テナント設定の統一 (今回完了)

#### 1. API エリアで `Tenant.current_id` を設定
- `app/controllers/api/v1/application_controller.rb` に `set_tenant` を追加
- リクエストヘッダー `X-Tenant-ID` からテナント ID を取得
- テナントが見つからない場合は適切なエラーレスポンスを返す

#### 2. AdminArea の `set_tenant` を統一
- `app/controllers/admin_area/application_controller.rb` を修正
- `RequestStore.store[:current_tenant] = tenant_id.to_sym` から `Tenant.current_id = tenant_id` に変更

#### 3. RulerArea の `set_tenant` を統一
- `app/controllers/ruler_area/application_controller.rb` の `set_tenant` を修正
- `Tenant.current_id = @tenant.id` を使用するよう変更
- `AdminsController` と `OauthProvidersController` は親クラスの `set_tenant` を継承
- `TenantsController` は `params[:id]` を使用するため独自の `set_tenant` を維持

## 現在の状態

### テナント設定の方法
| エリア | テナント ID 取得元 | 設定方法 |
|--------|-------------------|----------|
| API | `request.subdomain` | `Tenant.current_id = tenant_id` |
| AdminArea | `request.subdomain` | `Tenant.current_id = tenant_id` |
| RulerArea | `params[:tenant_id]` or `params[:id]` | `Tenant.current_id = @tenant.id` |

### 確認済みの正常動作
- データベースレベルの制約（外部キー、複合インデックス）は適切
- `Multitenancy` concern による `default_scope` が全モデルに適用済み
- 全エリアで `Tenant.current_id=` による統一的なテナント設定

## 次のステップ（オプション）
- テストでテナント分離が正しく動作することを確認
- API ドキュメントに `X-Tenant-ID` ヘッダーの説明を追加
